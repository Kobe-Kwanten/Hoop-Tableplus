#!/bin/bash

cleanup() {
  echo "Cleaning up..."
  if ps -p "$hoop_pid" > /dev/null; then
    kill "$hoop_pid"
    echo "Hoop process killed."
  fi
#  tput rmcup
  exit

}

# Set trap to call cleanup on script exit or termination
trap cleanup EXIT
trap cleanup SIGINT SIGTERM

echo "Logging in ..."

hoop login
if [ $? -ne 0 ]; then
  echo "Failed to log in. Exiting."
  exit 1
fi

echo "Which connection do you want to use?"
echo ""

connections=$(hoop admin get connections)
if [ -z "$connections" ]; then
  echo "No available connections found"
  exit 1
fi

echo -e "\033[32m$connections\033[0m"
echo ""

connection_names=($(echo "$connections" | awk '{print $1}'))

while true; do
  read -p "Enter the name of the connection: " connection_name

  if [[ " ${connection_names[@]} " =~ " $connection_name " ]]; then
    break
  else
    echo "Invalid connection name. Please try again."
  fi
done

connected=false
port=5433
while ! $connected; do
  echo "Opening connection ${connection_name} on port ${port}... "
  hoop connect "$connection_name" -p "$port" > /tmp/hoop_output.log 2>&1 &
  hoop_pid=$!

  while true; do
    if grep -q "connection:" /tmp/hoop_output.log && grep -q "postgres-credentials" /tmp/hoop_output.log; then
      connected=true
      break
    elif grep -q "address already in use" /tmp/hoop_output.log ; then
      echo "Port already in use"
      port=$((port + 1))
      break
    elif grep -q "connection not found" /tmp/hoop_output.log; then
      echo "Connection does not exist"
      exit 1
    else
      sleep 1
    fi
  done
done

connection_info=$(grep -m1 "connection:" /tmp/hoop_output.log)
postgres_credentials=$(awk '/^--------------------postgres-credentials--------------------$/,/^------------------------------------------------------------$/' /tmp/hoop_output.log)

if [ -z "$connection_info" ] || [ -z "$postgres_credentials" ]; then
  echo "Failed to retrieve connection or credentials information. Exiting."
  kill "$hoop_pid"
  exit 1
fi

echo ""
echo "$connection_info"
echo "$postgres_credentials"

host=$(echo "$postgres_credentials" | grep -o 'host=[^ ]*' | cut -d '=' -f 2)
port=$(echo "$postgres_credentials" | grep -o 'port=[^ ]*' | cut -d '=' -f 2)
user=$(echo "$postgres_credentials" | grep -o 'user=[^ ]*' | cut -d '=' -f 2)
password=$(echo "$postgres_credentials" |  grep -o 'password=[^ ]*' | cut -d '=' -f 2)

databases=$(PGPASSWORD="$password" psql -U "${user}" -h 127.0.0.1 -p "$port" -d postgres -c "SELECT datname FROM pg_database;")
database_names=($(echo "$databases" |awk 'NR > 2 {print $1}'))

echo ""
echo "Available databases:"
echo ""

#Remove count of rows from result (e.g. 10 rows)
filtered_database_names=()
for ((i=0; i<${#database_names[@]}-1; i++)); do
    echo -e "\033[32m  - ${database_names[i]}\033[0m"
    filtered_database_names+=("${database_names[i]}")
done

echo ""

while true; do
  read -p "Enter the name of the database to connect to: " dbName

  # Check if the entered database name is valid
  if [[ " ${filtered_database_names[@]} " =~ " $dbName " ]]; then
    # Clear only the database-related output
    break
  else
    echo "Invalid database name. Please try again."
  fi
done


# Start TablePlus process
tableplus_url="postgresql://$user:$password@$host:$port/$dbName"
echo "TablePlus URL: $tableplus_url"
open -W -a TablePlus "$tableplus_url" &
tableplus_pid=$!

# Wait for TablePlus process to finish
wait $tableplus_pid

# Cleanup will be automatically called when the script exits
