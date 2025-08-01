# OSDI 2025 Detailed Review

**Paper Title:** Towards Agentic OS: An LLM Agent Framework for Linux Schedulers

**Reviewer:** OSDI PC Member

**Overall Rating:** 4/5 (Strong Accept)

**Confidence:** 4/5 (Expert in systems, familiar with ML for systems)

## Summary

This paper presents SchedCP, a framework that enables Large Language Model (LLM) agents to safely and efficiently optimize Linux schedulers. The key insight is architecting a decoupled control plane that separates AI's semantic reasoning from the system's safe execution. The authors implement sched-agent, a multi-agent system that demonstrates this approach by achieving up to 80% performance improvement on kernel compilation with 88% cost reduction compared to naive approaches.

## Strengths

### S1: Addresses a Critical and Timely Problem

The semantic gap between application requirements and kernel scheduling policies is a fundamental challenge in modern systems. The paper articulates this well:
- Cloud operators manage schedulers without understanding application behavior
- Developers lack kernel expertise to optimize for their workloads  
- Dynamic workloads change faster than humans can adapt

This problem is increasingly important as workloads become more diverse and dynamic.

### S2: Clean and Principled System Design

The architectural separation between SchedCP (stable system interface) and sched-agent (AI logic) is elegant and well-motivated. The four design principles are particularly strong:

1. **Decoupling**: Separating "what to optimize" (AI) from "how to observe and act" (system)
2. **Safety-First**: Treating AI as potentially non-cautious actor
3. **Context Balance**: Adaptive provisioning to manage token costs
4. **Composable Tools**: Unix philosophy applied to AI agents

This design ensures the framework remains relevant as AI capabilities evolve.

### S3: Production-Ready Implementation

Unlike many research prototypes, this system is built on production infrastructure:
- Uses sched_ext (merged in Linux 6.12) for safe scheduler loading
- eBPF provides memory safety and verification
- Multi-stage validation pipeline (static analysis → sandbox testing → canary deployment)
- Circuit breaker mechanism for automatic rollback

The implementation details show serious consideration of deployment challenges.

### S4: Comprehensive Evaluation with Strong Results

The evaluation demonstrates significant improvements across multiple dimensions:
- **Performance**: 80% speedup on kernel compilation, 50% latency reduction on schbench
- **Cost**: 88% reduction from $6 to $0.75 per scheduler
- **Efficiency**: Generation time reduced from 33 minutes to 5 minutes
- **Reliability**: Success rate improved from 65% to 95%

The evaluation covers diverse metrics and shows the practical viability of the approach.

### S5: Broader Vision and Impact

The paper goes beyond schedulers to envision a unified OS optimization framework. The discussion of extending to cache policies, DVFS, and network configuration shows the generality of the approach. The democratization aspect—making expert-level optimization accessible to non-experts—is compelling.

## Weaknesses

### W1: Limited Comparison with State-of-the-Art ML Schedulers

While the paper compares against CFS and naive LLM approaches, it lacks comparison with recent ML-based scheduling systems:
- No comparison with Decima (GNN-based datacenter scheduling)
- Missing comparison with FIRM or other RL-based schedulers
- No discussion of how semantic understanding compares to statistical learning

This makes it difficult to assess the true advantage of the LLM approach over existing ML methods.

### W2: Scalability Concerns Not Adequately Addressed

The evaluation is limited to a 32-core system, which raises several concerns:
- How does the approach scale to hundreds or thousands of cores?
- What is the cost model for datacenter-scale deployment?
- How does the framework handle distributed scheduling across multiple nodes?
- Token costs could become prohibitive at scale

### W3: Limited Workload Diversity in Evaluation

The evaluation focuses heavily on CPU-intensive workloads:
- Kernel compilation
- Scheduler benchmarks (schbench)
- Batch processing workloads

Missing important workload categories:
- ML training (with distinct phases)
- Database workloads (OLTP/OLAP)
- Microservices with complex communication patterns
- Real-time or latency-critical applications

### W4: Insufficient Safety and Security Analysis

While the paper describes safety mechanisms, the analysis is incomplete:
- No formal verification of the Execution Verifier
- No discussion of adversarial attacks on AI-generated schedulers
- What happens if malicious code passes all validation stages?
- No worst-case performance analysis
- Missing discussion of security implications of giving AI kernel access

### W5: Learning Component Underspecified

The Learning Agent and long-term knowledge evolution need more detail:
- How does the system handle conflicting performance data?
- What happens with concept drift as workloads evolve?
- How is the Scheduler Policy Repository maintained and curated?
- No evaluation of long-term learning effectiveness

## Detailed Technical Comments

### Architecture and Implementation

1. **MCP Interface**: The use of Model Context Protocol is clever, but the paper should discuss:
   - API versioning and backward compatibility as kernel evolves
   - Performance overhead of the MCP bridge
   - Security implications of exposing kernel internals via MCP

2. **Multi-Agent Design**: While the four-agent decomposition (Observation, Planning, Execution, Learning) is logical, the paper could better justify why this specific decomposition was chosen over alternatives.

3. **Code Generation Pipeline**: The paper mentions AI-generated code "often exhibited poor quality" but doesn't provide:
   - Metrics for code quality assessment
   - Examples of common failure modes
   - How the framework improves code quality over time

### Evaluation Methodology

1. **Cost Analysis**: While showing 88% cost reduction, the absolute cost of $0.75 per scheduler may still be high:
   - Need breakdown of costs (profiling vs. generation vs. validation)
   - Total cost of ownership including infrastructure
   - Cost-benefit analysis for different deployment scenarios

2. **Performance Metrics**: The evaluation could be strengthened with:
   - Tail latency analysis (p99.9, p99.99)
   - Performance variance and stability metrics
   - Resource utilization efficiency
   - Energy consumption analysis

3. **RL Integration**: The 10-12% improvement from RL seems modest:
   - Why not use more sophisticated RL algorithms?
   - How does RL performance scale with training time?
   - Comparison with pure RL approaches

### System Design Decisions

1. **Workload Profiling**: The paper could better explain:
   - How long profiling takes for different workload types
   - Accuracy of workload classification across different domains
   - Handling of multi-phase or evolving workloads

2. **Scheduler Repository**: More details needed on:
   - Version control and rollback mechanisms
   - Conflict resolution when multiple schedulers target similar workloads
   - Quality metrics for repository curation

## Minor Issues

### Writing and Presentation

1. Section 3.2 (Motivation Experiment) could be moved earlier to better motivate the design
2. Some technical sections are dense and could benefit from more examples
3. The four design principles could be illustrated with concrete scenarios

### Missing or Incomplete Figures

1. Figure 2 is referenced but missing from the document
2. Figure 3 (performance comparison) contains placeholder text
3. Would benefit from architecture diagrams showing agent interactions

### Related Work

1. Could better position against recent work in learned indexes and learned query optimization
2. Missing discussion of LLM applications in other systems domains
3. Should compare with auto-tuning systems beyond schedulers

## Questions for Authors

1. **Adversarial Robustness**: How does the system handle adversarial workloads specifically designed to exploit weaknesses in AI-generated schedulers?

2. **Multi-tenant Scenarios**: How does the framework handle multiple applications with conflicting scheduling requirements on the same system?

3. **Real-time Adaptation**: Can the framework support online scheduler adaptation during workload execution, or is it limited to offline optimization?

4. **Debugging Support**: When an AI-generated scheduler performs poorly, what tools exist to help developers understand and fix the issue?

5. **Comparison Methodology**: Why wasn't the system compared against state-of-the-art ML schedulers like Decima? Is this a fundamental limitation or future work?

6. **Production Deployment**: Are there any production deployments planned or in progress? What are the main barriers to adoption?

## Detailed Recommendations for Revision

### Must Address

1. **Add comparison with ML-based schedulers**: Include evaluation against Decima, FIRM, or similar systems to show advantages of semantic understanding

2. **Scalability analysis**: Provide evaluation on larger systems and discuss datacenter-scale deployment costs and challenges

3. **Security analysis**: Add formal analysis of safety properties and discuss potential attack vectors and mitigations

4. **Workload diversity**: Expand evaluation to include ML training, databases, and microservices

### Should Address

1. **Learning evaluation**: Provide long-term study showing how the system improves over time

2. **Code quality metrics**: Quantify the quality of AI-generated code and show improvement mechanisms

3. **Cost breakdown**: Provide detailed analysis of where costs are incurred and optimization opportunities

### Nice to Have

1. **Case studies**: Real-world deployment experiences would strengthen the paper

2. **Open source release**: Commitment to releasing SchedCP would increase impact

3. **Formal verification**: Proving safety properties of the Execution Verifier would be valuable

## Final Assessment

This paper makes significant contributions to an important and timely problem. The clean architectural design, production-ready implementation, and strong evaluation results demonstrate both research novelty and practical impact. While there are valid concerns about scalability, safety guarantees, and comparison with existing ML approaches, these do not diminish the core contributions.

The work opens an exciting new direction for OS research, showing how LLMs can democratize system optimization. The principled design ensures the framework will remain relevant as AI capabilities evolve. With revisions addressing the main weaknesses, this paper would make an excellent addition to OSDI.

**Recommendation**: Strong Accept, contingent on addressing scalability and safety concerns in the revision.

**Confidence**: High (4/5) - Expert in operating systems and distributed systems, familiar with ML for systems and eBPF technology.