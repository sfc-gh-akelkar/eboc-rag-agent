import streamlit as st
from snowflake.snowpark.context import get_active_session
import json

AGENTS = {
    "All Specialties": "EBOC_UNIVERSAL_AGENT",
    "Neurology": "EBOC_NEUROLOGY_AGENT",
    "Cardiology": "EBOC_CARDIOLOGY_AGENT",
    "Respiratory": "EBOC_RESPIRATORY_AGENT",
    "Infection": "EBOC_INFECTION_AGENT",
}

AGENT_DB = "EXPLORER_SANDBOX"
AGENT_SCHEMA = "EBOC_RAG"


def init_session_state():
    if "messages" not in st.session_state:
        st.session_state.messages = []


def run_agent(session, agent_name, user_question):
    fqn = f"{AGENT_DB}.{AGENT_SCHEMA}.{agent_name}"
    request_body = json.dumps({
        "messages": [
            {"role": "user", "content": [{"type": "text", "text": user_question}]}
        ],
        "stream": False,
    })
    sql = f"""
        SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
            '{fqn}',
            $${request_body}$$
        ) AS response
    """
    result = session.sql(sql).collect()[0]["RESPONSE"]
    parsed = json.loads(result)

    answer_parts = []
    citations = []
    for block in parsed.get("content", []):
        if block.get("type") == "text":
            answer_parts.append(block["text"])
        elif block.get("type") == "tool_results":
            for tr in block.get("tool_results", []):
                if tr.get("type") == "cortex_search":
                    for res in tr.get("results", []):
                        citations.append({
                            "guideline": res.get("guideline_name", ""),
                            "section": res.get("section", ""),
                            "source_url": res.get("source_url", ""),
                        })

    return "\n".join(answer_parts), citations


def main():
    st.set_page_config(
        page_title="EBOC Clinical Guidelines Assistant",
        page_icon="🏥",
        layout="wide",
    )

    st.title("EBOC Clinical Guidelines Assistant")
    st.caption("TCH — Evidence-Based Outcomes Center")

    with st.sidebar:
        st.header("Settings")
        specialty = st.selectbox("Specialty", list(AGENTS.keys()))
        st.divider()
        if st.button("Clear Conversation"):
            st.session_state.messages = []
            st.rerun()
        st.divider()
        st.markdown(
            "**Disclaimer:** This tool is for reference only. "
            "Always verify recommendations with the full guideline document."
        )
        st.markdown("---")
        st.markdown(
            "**Sample Questions:**\n"
            "- What is the recommended workup for a first unprovoked seizure?\n"
            "- What are the diagnostic criteria for Kawasaki disease?\n"
            "- When should HFNC be initiated for bronchiolitis?\n"
            "- What antibiotics are recommended for community-acquired pneumonia?\n"
            "- What is the initial fluid resuscitation protocol for DKA?"
        )

    init_session_state()
    session = get_active_session()

    for msg in st.session_state.messages:
        with st.chat_message(msg["role"], avatar="🏥" if msg["role"] == "assistant" else "👤"):
            st.markdown(msg["content"])
            if msg.get("citations"):
                with st.expander("📄 Sources"):
                    for c in msg["citations"]:
                        if c.get("source_url"):
                            st.markdown(f"- [{c['guideline']}]({c['source_url']}) — {c.get('section', '')}")
                        else:
                            st.markdown(f"- {c['guideline']} — {c.get('section', '')}")

    if question := st.chat_input("Ask a clinical question..."):
        st.session_state.messages.append({"role": "user", "content": question})
        with st.chat_message("user", avatar="👤"):
            st.markdown(question)

        with st.chat_message("assistant", avatar="🏥"):
            with st.spinner("Searching EBOC guidelines..."):
                agent_name = AGENTS[specialty]
                answer, citations = run_agent(session, agent_name, question)
                st.markdown(answer)
                if citations:
                    with st.expander("📄 Sources"):
                        seen = set()
                        for c in citations:
                            key = c.get("guideline", "")
                            if key and key not in seen:
                                seen.add(key)
                                if c.get("source_url"):
                                    st.markdown(f"- [{c['guideline']}]({c['source_url']}) — {c.get('section', '')}")
                                else:
                                    st.markdown(f"- {c['guideline']} — {c.get('section', '')}")

        st.session_state.messages.append({
            "role": "assistant",
            "content": answer,
            "citations": citations,
        })


if __name__ == "__main__":
    main()
