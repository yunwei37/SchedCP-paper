---
theme: seriph
background: https://cover.sli.dev
title: 'SchedCP: Autonomous OS Optimization with LLM Agents'
info: |
  ## SchedCP: Autonomous OS Optimization with LLM Agents
  A framework for safe, efficient, and autonomous performance tuning.
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
---

# SchedCP: Autonomous OS Optimization

**A Framework for LLM Agents to Safely Tune the Linux Scheduler**

<div class="abs-br m-6 text-sm opacity-50">
  Class Project Presentation
</div>

---

# Slide 1: The Semantic Gap & Our Insight

## Problem: Schedulers Lack Application-Specific Context

<div class="grid grid-cols-2 gap-8">
<div>

### The Semantic Gap
- Kernel schedulers use generic, one-size-fits-all policies.
- They fail to understand application-specific needs (e.g., latency vs. throughput).
- This leads to avoidable performance loss and inefficient resource use.

</div>
<div>

### Why Naïve Solutions Fail
- Directly asking an LLM to "write kernel code" is brittle, unsafe, and slow.
- It often degrades performance and misses the true optimization goal.

</div>
</div>

---

### Our Insight: Decouple Reasoning from Execution

A structured control plane is needed to separate the two key stages of optimization:

1.  **Goal Inference (The "What")**: The AI's role. Autonomously analyze workload behavior to determine the *semantic goal* (e.g., "minimize p99 latency").
2.  **Policy Synthesis (The "How")**: The System's role. Translate the goal into a safe, verifiable scheduling policy using robust tools and interfaces.

**Takeaway**: We enable agents to be goal-oriented thinkers, not just unsafe code generators.

---

# Slide 2: Architecture — The SchedCP Control Plane

## A Framework for Safe, Autonomous Optimization

SchedCP is an MCP server that provides a stable, verifiable interface for LLM agents.

<div class="grid grid-cols-2 gap-6">

<div>

### SchedCP: The Control Plane
Provides three key services for agents:

**1. Workload Analysis Engine**
- Ingests traces, profiles, and metrics.
- Surfaces performance bottlenecks and candidate SLOs.

**2. Scheduler Policy Repository**
- An evolving library of eBPF scheduler patterns and templates.
- Enables safe, compositional policy creation.

**3. Execution Verifier**
- Statically and dynamically analyzes all generated code and configurations *before* deployment.
- Guarantees safety and stability.

</div>
<div>

### `sched-agent`: The Autonomous Agent
A multi-agent system that uses SchedCP to optimize:

**Observation Agent**
- Monitors system signals to identify optimization opportunities.

**Planning Agent**
- Infers goals and selects optimization strategies.

**Execution Agent**
- Synthesizes and deploys eBPF policies via `sched_ext`.

**Learning Agent**
- Evaluates outcomes and refines policies over time.

</div>
</div>

<div class="mt-4 text-center">

**Result**: A closed-loop system where agents reason about *what* to do, and SchedCP provides the safe tools for *how* to do it.

</div>

<div class="mt-6">

<img src="/arch-schedcp.png" class="mx-auto rounded shadow-lg" style="max-height: 350px;" alt="SchedCP Architecture Diagram" />

<div class="text-xs mt-2 opacity-70 text-center">
Architecture: SchedCP Control Plane with multi-agent system
</div>

</div>

---

# Slide 3: Results & Key Achievements

## Autonomous Agents Achieve Expert-Level Performance

Our evaluation shows that `sched-agent`, powered by SchedCP, can autonomously and significantly improve system performance.

### Representative Performance Gains
- **1.79×** faster kernel compilation (throughput).
- **2.11×** lower P99 latency on `schbench`.
- **1.60×** higher throughput on `schbench`.
- **13×** cost reduction vs. naïve "code-gen" agentic approaches.

### What This Proves
1.  **The Architecture Works**: Decoupling reasoning from execution is the right model for agentic OS optimization.
2.  **Full Autonomy is Viable**: The system operates safely and effectively with no human in the loop.
3.  **It's Efficient**: The control plane drastically reduces the cost and complexity of using LLMs for this task.

### Current Scope & Future Work
- **Focus**: CPU scheduling via `sched_ext` and eBPF.
- **Next Steps**: Extend the framework to other OS subsystems (I/O, memory, power) and develop a standardized benchmark to drive reproducible research in this new field.

<div class="mt-6">

<div class="grid grid-cols-3 gap-4">

<div>
<img src="/linux-build-results.png" class="rounded shadow-lg" alt="Linux Build Benchmark Results" />
<div class="text-xs mt-1 opacity-70 text-center">Linux Kernel Build Performance</div>
</div>

<div>
<img src="/schbench-results.png" class="rounded shadow-lg" alt="Schbench Performance Comparison" />
<div class="text-xs mt-1 opacity-70 text-center">Schbench Latency & Throughput</div>
</div>

<div>
<img src="/scheduler-comparison.png" class="rounded shadow-lg" alt="Scheduler Performance Comparison" />
<div class="text-xs mt-1 opacity-70 text-center">Overall Scheduler Comparison</div>
</div>

</div>

</div>

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
