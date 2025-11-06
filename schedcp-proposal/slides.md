---
theme: seriph
background: https://cover.sli.dev
title: Agentic OS Optimization
info: |
  ## Agentic OS Optimization: Workshop Paper & Benchmark Proposal
  LLM Agents for Linux Scheduling and Benchmark Design
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
---

# Agentic OS Optimization

**Workshop Paper & Benchmark Proposal**

<div class="abs-br m-6 text-sm opacity-50">
  Class Project Presentation
</div>

---

# Slide 1: Problem & Key Insight

## Towards Agentic OS: LLM Agents for Linux Scheduling

### The Gap
- Kernel schedulers use generic policies that don't understand per-application intent
- Latency vs throughput vs fairness trade-offs are hardcoded
- Results in avoidable performance loss

### Why Naïve "LLM writes the kernel" Fails
- Direct code-gen is slow, expensive, and brittle
- Often degrades performance instead of improving it

### Key Insight: Decouple Reasoning from Execution
**Semantic reasoning** ("What should the system optimize?") + **System execution** ("How to observe and act?")

### Our System
- **SchedCP**: Control plane with stable, safe interfaces (profiling, tracing, validation)
- **sched-agent**: Multi-agent system that infers goals and synthesizes scheduling policies (eBPF via sched_ext)

**Takeaway**: Treat agentic OS optimization as goal-oriented, closed-loop control—not code generation

---

# Slide 2: Architecture & Multi-Agent System

## SchedCP Control Plane + sched-agent

<div class="grid grid-cols-2 gap-6 text-sm">

<div>

### SchedCP (MCP Server)

**Workload Analysis Engine**
- Collects traces/counters
- Surfaces bottleneck hypotheses and candidate SLOs

**Scheduler Policy Repository**
- Templates & patterns for eBPF policies
- Custom queuing, preemption, priority rules

**Execution Verifier**
- Static/dynamic checks
- Validates configs and code before deployment

</div>

<div>

### sched-agent (Multi-Agent System)

**Observation Agent**
- Collects signals (perf, ftrace, BPF)
- Identifies pathologies

**Planning Agent**
- Chooses optimization goals & tactics
- Within SLO/budget constraints

**Execution Agent**
- Instantiates/adapts eBPF policies
- Via sched_ext

**Learning Agent**
- Evaluates outcomes
- Logs lessons, refines policies

</div>

</div>

<div class="mt-6 text-center">

```
┌─────────────────────┐
│ Agentic Reasoning   │
│ (Goal Inference)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│     SchedCP         │
│ Analysis/Repo/      │
│ Verifier            │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Kernel (sched_ext)  │
└─────────────────────┘
      ▲
      │ Runtime Metrics
      └─────────────────
```

</div>

**Why it works**: Agents reason over semantics using safe, composable tools; kernel changes are guarded by verification

---

# Slide 3: Workshop Results & Limitations

## What the Workshop Version Demonstrated

### Representative Results
- **1.79×** performance improvement on kernel compile
- **~2.11× P99 latency improvement** on schbench
- **~1.60× throughput gain** on schbench
- **~20% latency reduction** on batch workloads
- **~13× cost reduction** vs. naïve agentic approaches

### Key Insights
- Architecture (MCP + policy repository + verifier) matters more than model size alone
- Independent of a single LLM

### Limitations & Realities
- Scope: mainly CPU scheduling via sched_ext and eBPF
- Other subsystems (I/O, caching, DVFS) not evaluated
- Results depend on workload mix and verification guardrails
- Generalization unproven

### Critical Implication
**The field needs a standardized, reproducible benchmark** to measure progress across agents, models, and OS subsystems—not just ad-hoc demos

---

# Slide 4: Benchmark Proposal — Design & Evaluation

## A Reproducible Benchmark for Agentic OS Optimization

### Goal
Evaluate LLM agent's ability to optimize OS behavior for diverse workloads under explicit **SLOs** and **budgets** (time, tokens, CPU/energy)

### Task Design (2-Phase Challenge)
1. **Goal Inference**: From traces/metrics/logs, infer bottlenecks & optimization targets
2. **Policy/Tool Synthesis**: Select/configure tools OR synthesize code (eBPF schedulers) to meet SLOs

### Evaluation Axes

<div class="grid grid-cols-2 gap-4 text-sm">

<div>

**Primary Metrics**
- Latency (P50/P99)
- Throughput
- Fairness
- Energy

**Constraint Satisfaction**
- SLO adherence (hard/soft)
- Safety (no crashes, verifier passes)
- Budget usage (wall-clock, tokens, CPU)

</div>

<div>

**Generalization**
- Performance on held-out workloads
- Unseen SLOs

**Scoring Formula**
```
I_{w,m} = Baseline / Agent  (latency; lower better)
I_{w,m} = Agent / Baseline  (throughput; higher better)

Score = Σ_w [(Σ_m α_m · I_{w,m}) · 1[hard SLOs met]]
        - λ · BudgetOveruse
```

</div>

</div>

### Tracks (Avoid Apples-to-Oranges)
- **T1 Config-only**: Change kernel/user-space knobs; no code-gen
- **T2 Code-gen allowed**: eBPF policy synthesis via sched_ext with verification
- **T3 Multi-subsystem**: Scheduling + (I/O, caching, or DVFS), gated behind safety

---

# Slide 5: Workloads, Baselines & Implementation Plan

## Concrete Scope & Deliverables

### Initial Workload Suite (~20)

<div class="grid grid-cols-2 gap-4 text-sm">

<div>

**CPU-bound batch**
- kernel make, LLVM build
- xz/gzip, ffmpeg

**Latency-critical**
- schbench, hackbench
- context-switch patterns

**Server-like**
- nginx+wrk
- Redis+memtier (CPU contention)

</div>

<div>

**Analytics**
- sort/join pipelines
- SQLite queries
- map-reduce toy

**Stress/perturbation**
- memory pressure
- CPU pinning noise
- power-save governors

</div>

</div>

Each workload: **clear SLOs** + **repeatable harness**

### Baselines (Principled & Reproducible)
- Human-tuned Linux defaults (CFS/EEVDF with documented knobs)
- Adaptive/ML baselines (published RL/config learners)
- Naïve agent baselines (prompt-only code-gen without control-plane)

### Benchmark Harness (Extensible & Safe)
- **Runner**: Containers/VMs, time-series collection, pinned kernel version
- **Agent Sandbox**: MCP tool server + Verifier gate
- **Evaluator**: Multi-run statistics, SLO checks, signed result bundles
- **Reproducibility**: Fixed seeds, cold/warm start, hardware profiles

### Implementation Plan

<div class="text-sm">

**M1 (Framework)**: Runner + evaluator + MCP server; 6 workloads; T1 track

**M2 (Safety & Code-gen)**: Verifier + sched_ext; eBPF repo; 12 workloads; T2 track

**M3 (Breadth & Leaderboard)**: 20+ workloads; CI validation; public website; T3 pilot

</div>

### Risks & Mitigations
- **Kernel safety** → verification gates, kill-switch, non-root BPF
- **Evaluation flakiness** → multi-run medians, variance filters, power capping
- **Model cost** → strict budgets, caching, cost-normalized scores
- **Gaming** → hidden workloads/SLOs, log attestation, policy diff checks

**Bottom line**: Without a public, hardened benchmark, "agentic OS" won't move beyond one-off demos

---
layout: center
class: text-center
---

# Thank You

**Reference**: Zheng et al., "Towards Agentic OS: An LLM Agent Framework for Linux Schedulers," MLforSystem 2025

Questions?
