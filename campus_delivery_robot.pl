% Campus Delivery Robot
% Prolog planning demo
%
% Package 1: Library -> Computer Science
% Package 2: Administration -> Science Building
% Constraint: the robot can carry only one package at a time.
%
% Main commands:
%   ?- demo.
%   ?- demo_trace.
%   ?- solve(Plan).

:- use_module(library(lists)).

% ------------------------------------------------------------
% CAMPUS MAP
% ------------------------------------------------------------

road(student_center, library).
road(library, science_building).
road(science_building, computer_science).
road(student_center, administration).
road(administration, computer_science).

% Roads are usable in both directions.
connected(A, B) :- road(A, B).
connected(A, B) :- road(B, A).

% ------------------------------------------------------------
% PACKAGE DESTINATIONS
% ------------------------------------------------------------

destination(package1, computer_science).
destination(package2, science_building).

% ------------------------------------------------------------
% STATE
% ------------------------------------------------------------
%
% state(RobotLocation, PackageList, Carrying)
%
% Package statuses are:
%   a campus location
%   carried
%   delivered

initial_state(
    state(
        student_center,
        [package(package1, library),
         package(package2, administration)],
        none
    )
).

goal_state(state(_, Packages, none)) :-
    all_delivered(Packages).

all_delivered([]).
all_delivered([package(_, delivered) | Rest]) :-
    all_delivered(Rest).

% Change one package's status while keeping the list order.
replace_package(Package, Old, New,
                [package(Package, Old) | Rest],
                [package(Package, New) | Rest]).

replace_package(Package, Old, New,
                [First | Rest],
                [First | UpdatedRest]) :-
    replace_package(Package, Old, New, Rest, UpdatedRest).

% ------------------------------------------------------------
% ACTIONS
% ------------------------------------------------------------

% DELIVER
% Legal only if the robot is carrying the package and is at
% that package's destination.
action(
    state(Location, Packages, Package),
    deliver(Package),
    state(Location, UpdatedPackages, none)
) :-
    destination(Package, Location),
    replace_package(
        Package, carried, delivered,
        Packages, UpdatedPackages
    ).

% PICKUP
% Legal only if the robot is carrying nothing and the package
% is at the robot's current location.
%
% "none" is what enforces the one-package carrying limit.
action(
    state(Location, Packages, none),
    pickup(Package),
    state(Location, UpdatedPackages, Package)
) :-
    member(package(Package, Location), Packages),
    replace_package(
        Package, Location, carried,
        Packages, UpdatedPackages
    ).

% MOVE
% Legal only if the two locations are connected.
action(
    state(From, Packages, Carrying),
    move(From, To),
    state(To, Packages, Carrying)
) :-
    connected(From, To).

% ------------------------------------------------------------
% PLANNER
% ------------------------------------------------------------
%
% Iterative deepening:
% try a 0-action plan, then 1, then 2, and so on.
% The first solution found is therefore a shortest plan under
% this model.

solve(Plan) :-
    initial_state(Start),
    between(0, 30, Depth),
    length(Plan, Depth),
    plan(Start, [Start], Plan),
    !.

% Base case: no actions remain, so the current state must
% already satisfy the goal.
plan(State, _, []) :-
    goal_state(State).

% Recursive case:
% 1. choose a legal action
% 2. generate the next state
% 3. reject repeated states
% 4. keep searching
plan(State, Visited, [Action | Rest]) :-
    action(State, Action, NextState),
    \+ memberchk(NextState, Visited),
    plan(NextState, [NextState | Visited], Rest).

% ------------------------------------------------------------
% READABLE NAMES
% ------------------------------------------------------------

location_name(student_center, 'Student Center').
location_name(library, 'Library').
location_name(science_building, 'Science Building').
location_name(computer_science, 'Computer Science').
location_name(administration, 'Administration').

package_name(package1, 'Package 1').
package_name(package2, 'Package 2').

% ------------------------------------------------------------
% MAIN DEMO
% ------------------------------------------------------------

demo :-
    nl,
    writeln('=================================================='),
    writeln(' CAMPUS DELIVERY ROBOT - PROLOG PLANNING DEMO'),
    writeln('=================================================='),
    nl,
    writeln('Starting situation:'),
    writeln('- Robot starts at the Student Center.'),
    writeln('- Package 1: Library -> Computer Science'),
    writeln('- Package 2: Administration -> Science Building'),
    writeln('- Constraint: robot can carry only one package.'),
    nl,
    writeln('Searching for a valid shortest plan...'),
    nl,
    solve(Plan),
    writeln('PLAN FOUND'),
    writeln('----------'),
    print_plan(Plan, 1),
    length(Plan, Length),
    nl,
    format('Total actions: ~d~n', [Length]),
    writeln('Goal reached: both packages are delivered.'),
    nl.

print_plan([], _).
print_plan([Action | Rest], Step) :-
    format('~d. ', [Step]),
    print_action(Action),
    NextStep is Step + 1,
    print_plan(Rest, NextStep).

print_action(move(From, To)) :-
    location_name(From, FromName),
    location_name(To, ToName),
    format('Move from ~w to ~w.~n', [FromName, ToName]).

print_action(pickup(Package)) :-
    package_name(Package, PackageName),
    format('Pick up ~w.~n', [PackageName]).

print_action(deliver(Package)) :-
    package_name(Package, PackageName),
    format('Deliver ~w.~n', [PackageName]).

% ------------------------------------------------------------
% STATE TRACE DEMO
% ------------------------------------------------------------

demo_trace :-
    initial_state(Start),
    solve(Plan),
    nl,
    writeln('=================================================='),
    writeln(' CAMPUS DELIVERY ROBOT - STATE TRACE'),
    writeln('=================================================='),
    nl,
    writeln('Initial state:'),
    print_state(Start),
    nl,
    trace_plan(Start, Plan, 1).

trace_plan(State, [], _) :-
    nl,
    ( goal_state(State)
      -> writeln('FINAL RESULT: Goal state reached.')
      ;  writeln('FINAL RESULT: Goal state not reached.')
    ).

trace_plan(State, [Action | Rest], Step) :-
    action(State, Action, NextState),
    format('Step ~d: ', [Step]),
    print_action(Action),
    print_state(NextState),
    nl,
    NextStep is Step + 1,
    trace_plan(NextState, Rest, NextStep).

print_state(state(RobotLocation, Packages, Carrying)) :-
    location_name(RobotLocation, RobotName),
    format('  Robot location: ~w~n', [RobotName]),
    print_carrying(Carrying),
    print_packages(Packages).

print_carrying(none) :-
    writeln('  Carrying: nothing').

print_carrying(Package) :-
    Package \= none,
    package_name(Package, PackageName),
    format('  Carrying: ~w~n', [PackageName]).

print_packages([]).
print_packages([package(Package, Status) | Rest]) :-
    package_name(Package, PackageName),
    print_package_status(PackageName, Status),
    print_packages(Rest).

print_package_status(PackageName, carried) :-
    format('  ~w status: being carried~n', [PackageName]).

print_package_status(PackageName, delivered) :-
    format('  ~w status: delivered~n', [PackageName]).

print_package_status(PackageName, Location) :-
    Location \= carried,
    Location \= delivered,
    location_name(Location, LocationName),
    format('  ~w location: ~w~n', [PackageName, LocationName]).
