# computercraft_code

bootstrap.lua should be a program that lets a computer wget all the files it needs


### todo:
* equip commands check the tool type, and errors are thrown if a command needs a tool but its not there
* "safe route" metadata about base structure, and a protocol for running into other bots in transit
* reboot that uses a GPS cluster to get back to the start position, and maybe resume the task at hand
* config files for complex input to tasks
* movement routing to a faraway task such as mining
* fuel tracking, and automatically going back to a fuel store for more
* server chunk-loading beacon placement and self-cleanup (overlapping beacon placement to and from route)