# Team Ranking Application - Architecture Overview

## Introduction

This document outlines a description for a web application that allows users to rank teams in priority order. The
application enforces specific rules, ensuring users cannot rank their own team and respecting exclusion rules between
certain users and teams.

## Core Entities

### User

Each user can be one of the following categories:

- TeamMember: belongs to a team.  A TeamMember cannot vote for their own team.
- Judge: can rank all teams.
- Admin: can manage users, view rankings.  They are also have the same ability as a judge to rank all teams.

### Team
- Represents a group that will be ranked
- Contains multiple users
- May have exclusions that prevent them from ranking certain teams

### Ranking

Users have three rankings they provide:

- A ranking of teams according to their techical merrit
- A ranking of teams based on their commercial merrit
- A ranking of teams based on their overall merrit

### Exclusion

- Represents a restriction preventing a specific team from ranking another specific team

Create a schema to support this concept
