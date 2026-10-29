# Campus Delivery Robot — Prolog Planning Demo

This is a standalone SWI-Prolog project that demonstrates **AI planning**.

The robot starts at the **Student Center** and must deliver two packages:

- **Package 1:** Library → Computer Science
- **Package 2:** Administration → Science Building
- **Constraint:** the robot can carry only one package at a time.

The project is intentionally separate from the earlier faculty-scheduler project. Instead of mainly answering questions from stored facts, this program searches through possible **actions and changing states** until it reaches a goal.

## Files

- `campus_delivery_robot.pl` — complete Prolog planner
- `run_demo.bat` — Windows shortcut for the main demo

## Requirements

Install **SWI-Prolog** and make sure `swipl` works in a terminal.

Test:

```powershell
swipl --version
```

## Run the project

Start SWI-Prolog:

```powershell
swipl
```

Load the program:

```prolog
consult('campus_delivery_robot.pl').
```

Then run the main demo:

```prolog
demo.
```

You can also ask Prolog for the raw plan:

```prolog
solve(Plan).
```

For a state-by-state explanation:

```prolog
demo_trace.
```

To leave SWI-Prolog:

```prolog
halt.
```

## One-command Windows demo

From the VS Code terminal, you can also run:

```powershell
.\run_demo.bat
```

The batch file loads the Prolog program, runs `demo`, and exits automatically.

## What the planner models

A state contains three things:

```text
state(RobotLocation, PackageList, Carrying)
```

The initial state is conceptually:

```text
Robot location: Student Center
Package 1 location: Library
Package 2 location: Administration
Carrying: nothing
```

The goal is:

```text
Package 1: delivered
Package 2: delivered
Carrying: nothing
```

## Available actions

### Move

The robot can move only between connected campus locations.

Example:

```prolog
move(student_center, library)
```

### Pickup

A package can be picked up only when:

1. the robot is at the same location as the package, and
2. the robot is carrying nothing.

That second rule is how the project enforces the **one-package carrying capacity**.

### Deliver

A package can be delivered only when:

1. the robot is carrying it, and
2. the robot has reached that package's required destination.

## How Prolog finds the plan

`solve(Plan)` uses **iterative deepening**.

It asks:

```text
Can I solve this in 0 actions?
Can I solve this in 1 action?
Can I solve this in 2 actions?
...
```

For each length, Prolog uses its normal search and backtracking behavior to try legal actions.

The planner also keeps a list of states already visited on the current search path. That prevents the robot from endlessly moving in circles.

Because the program checks shorter plan lengths before longer ones, the first solution it accepts is a shortest plan under this model.

## Expected plan

One shortest plan is:

```text
1. Move from Student Center to Library.
2. Pick up Package 1.
3. Move from Library to Science Building.
4. Move from Science Building to Computer Science.
5. Deliver Package 1.
6. Move from Computer Science to Administration.
7. Pick up Package 2.
8. Move from Administration to Computer Science.
9. Move from Computer Science to Science Building.
10. Deliver Package 2.
```

The important point is that this sequence is **not stored as a hard-coded answer**. The program stores the map, package destinations, legal actions, initial state, and goal. Prolog searches for a valid sequence.
