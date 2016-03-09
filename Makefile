CLI_SNAME=cli
BRANCH=master

all: compile

depends:
	@mix do deps.get
	@MIX_ENV=local mix deps.compile --all

compile:
	@MIX_ENV=local mix do compile

clean:
	@mix do clean
	@mix deps.clean --all

run:
	@MIX_ENV=local mix phoenix.server

.PHONY: all depends compile clean run 
