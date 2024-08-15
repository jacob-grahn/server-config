#!/bin/bash

# Inputs
project=$1

# Stop project
docker compose --project-name $project down
