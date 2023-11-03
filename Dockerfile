# Use the official Elixir image
FROM elixir:1.15

# Install dependencies
RUN mix local.hex --force && \
    mix local.rebar --force

# Create and set the working directory
WORKDIR /app

# Copy the application files
COPY . .

# Install dependencies
RUN mix deps.get
RUN mix deps.compile

# Compile the application
RUN mix compile

# Run database migrations
RUN mix ecto.create
RUN mix ecto.migrate

# Build the release
RUN mix release

# Set up the entry point
CMD ["_build/prod/rel/relax_telegram_bot/bin/relax_telegram_bot", "start"]
