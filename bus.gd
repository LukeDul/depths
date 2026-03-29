extends Node

@warning_ignore_start("unused_signal")
signal player_interacted

signal dialogue_started()

signal dialogue_ended()

signal nudged(dialogue_resource: DialogueResource)

signal unnudged()

signal disco_available(verb: String)

signal disco_unavailable()

signal player_hit()
