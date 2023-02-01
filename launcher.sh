#!/bin/bash

# launcher

# start the backend
cd backend/cmd/server && ./egh-api &

# start the front end
npm run dev
