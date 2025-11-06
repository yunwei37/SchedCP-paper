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

# Goal and Insight

<div class="grid grid-cols-2 gap-8">
<div>

Goal: 

## Problem

- Kernel schedulers use generic, one-size-fits-all policies
- Fail to understand app-specific needs (latency vs. throughput, SLOs)
- Leads to avoidable performance loss

## Current solutions

- Adaptive or programable frameworks...
- RL methods...
- Direct tuning from LLM Agents is unsafe, and slow, may degrades performance

LLM should be control plane, not the data plane.

</div>
<div>

## Our Insight: Decouple Reasoning from Execution

</div>
</div>

---

# System Architecture: SchedCP & Multi-Agent Framework

<div class="grid grid-cols-2 gap-8 mt-6">

<div>

<img src="/arch-schedcp.png" class="rounded shadow-lg" style="max-height: 500px;" alt="SchedCP Architecture Diagram" />

</div>

<div>

### Control Plane: a MCP server

- Workload Analysis Engine
- Policy Repository (eBPF templates for code generation)
- Execution Verifier (safety checks)

### sched-agent

- **Observation** → Monitoring
- **Planning** → Goal inference with Reasoning
- **Execution** → Policy deployment
- **Learning** → Refinement

Key idea: 

</div>

</div>

---

# Preliminary Evaluations

<div class="grid grid-cols-2 gap-8 mt-4">

<div>

### Performance Gains

- **1.79× faster** kernel compilation
- **2.11× lower P99 latency** on schbench
- **1.60× higher throughput** on schbench
- **13× cost reduction** vs. naïve agents

### Limitaions & Next Steps

- Develop standardized benchmark framework for Agentic tasks
- Extend to I/O, memory, power subsystems

<div>
<img src="/linux-build-results.png" class="rounded shadow-lg" alt="Linux Build Benchmark Results" />
<div class="text-xs mt-1 opacity-70 text-center">Config: Kernel Build: <strong>1.79× faster</strong></div>
</div>

</div>

<div>

<div class="space-y-4">

<div>
<img src="/schbench-results.png" class="rounded shadow-lg" alt="Schbench Performance Comparison" />
<div class="text-xs mt-1 opacity-70 text-center">Config: Schbench: <strong>2.11× lower P99</strong>, <strong>1.60× throughput</strong></div>
</div>

<div>
<img src="/scheduler-comparison.png" class="rounded shadow-lg" alt="Scheduler Performance Comparison" />
<div class="text-xs mt-1 opacity-70 text-center">Overall Scheduler Comparison</div>
</div>

</div>

</div>

</div>

---

# Benchmark Framework Design & Evaluation Methodology

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

# Implementation Plan & Benchmark Specification

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
