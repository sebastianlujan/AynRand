# Build package
sui client build

# Publish package
sui client publish --gas-budget 100000000

# Save returned values
export PACKAGE_ID=<package_id_from_publish>
export ADMIN_CAP_ID=<admin_cap_id_from_publish>

# Get current timestamp
export CURRENT_TIME=$(date +%s000)  # milliseconds
export START_TIME=$CURRENT_TIME
export END_TIME=$((CURRENT_TIME + 3600000))  # 1 hour from now

# Get Clock ID
export CLOCK_ID=$(sui client objects --query-params type=0x2::clock::Clock | grep -oP '(?<="id": ")[^"]*' | head -1)

# Create raffle
sui client call \
    --package $PACKAGE_ID \
    --module raffle \
    --function create \
    --args $ADMIN_CAP_ID $START_TIME $END_TIME \
    --gas-budget 100000000

# Save returned raffle ID
export RAFFLE_ID=<raffle_id_from_output>

# Mint 10 tickets
sui client call \
    --package $PACKAGE_ID \
    --module raffle \
    --function mint_tickets_to_raffle \
    --args $ADMIN_CAP_ID $RAFFLE_ID "10" "RaffleTicket#1" $CLOCK_ID \
    --gas-budget 100000000

# First, get a coin object with sufficient funds (0.1 SUI = 100,000,000 MIST)
export COIN_ID=$(sui client gas --json | jq -r '.items[0].id')

# Buy ticket
sui client call \
    --package $PACKAGE_ID \
    --module raffle \
    --function buy_ticket \
    --args $RAFFLE_ID $COIN_ID $CLOCK_ID \
    --gas-budget 100000000

# Get Random object ID
export RANDOM_ID=$(sui client objects --query-params type=0x2::random::Random | grep -oP '(?<="id": ")[^"]*' | head -1)

# Draw winner
sui client call \
    --package $PACKAGE_ID \
    --module raffle \
    --function draw_winner \
    --args $RAFFLE_ID $CLOCK_ID $RANDOM_ID \
    --gas-budget 100000000

# Check raffle object state
sui client object $RAFFLE_ID

# Check ticket ownership
sui client objects

# Check events
sui client events --query-params "sender=$PACKAGE_ID"