extends CanvasLayer

## Which ending to show (1–4). Set before adding to the scene tree.
@export var ending_id: int = 1

## Scroll speed in pixels per second
@export var scroll_speed: float = 60.0

## Fade-to-black duration after text finishes scrolling
@export var fade_duration: float = 2.0

const ENDINGS: Dictionary = {
	1: "[left]Emily? Emily, are you awake?[/left]
[right]Mom? Is that you?[/right]
[left]Yes darling. How do you feel?[/left]
[right]Okay, I guess. Where are we?[/right]
[left]We’re in the hospital dear.[/left]
[right]Dad?[/right]
[left]Yes dear. Do you remember what happened?[/left]
[right]Not really. I was at the bridge. The one I always go to when I want to be alone. I must have fallen asleep.[/right]
[left]The doctor says you were just in time. If that couple hadn’t heard you, you might’ve…well, at least you’re ok.[/left]
[right]Where’s Agnes?[/right]
[left]Well, it’s funny you should ask…[/left]

[right]Em![/right]
[left]Agnes! You’re awake![/left]
[right]I missed you![/right]
[left]I missed you too. Agnes, I’m so sorry for what happened. This whole thing was my fault. I should never have tried to push you away.[/left]
[right]You didn’t push me away. You saved me![/right]
[left]What do you mean?[/left]
[right]I had a dream that I was in a dark place. You were there too, and Mr. Eli, and that creep you used to work with, I forgot his name.[/right]
[left]Rick.[/left]
[right]Yeah. But in the dream, you found me and started talking to me. I was scared, but you made me feel safe again. And I was able to get up, and I found the light and I came out, and then I woke up.[/right]

[left]Aw. Isn’t that sweet?[/left]
[right]Agnes, you have no idea how much has happened.[/right]
[left]I know that you saved me. You’re my guardian angel.[/left]
[right]And you’re my little lamb. Come here![/right]
[left]Hey! You’re squeezing me![/left]
[right]And I’m not gonna stop until you’re nothing but a pancake![/right]
[left]I love you Emily.[/left]
[right]I love you too Agnes.[/right]
[left]You got the Dream Ending[/left]",

	2: "[left]Emily? Emily, are you awake?[/left]
[right]Mom? Is that you?[/right]
[left]Yes darling. How do you feel?[/left]
[right]Okay, I guess. Where are we?[/right]
[left]We’re in the hospital dear.[/left]
[right]Dad?[/right]
[left]Yes dear. Do you remember what happened?[/left]
[right]Not really. I was at the bridge. The one I always go to when I want to be alone. I must have fallen asleep.[/right]
[left]The doctor says you were just in time. If that couple hadn’t heard you, you might’ve…well, at least you’re ok.[/left]
[right]Where’s Agnes?[/right]
[left]…[/left]
[right]Mom? Dad? Is Agnes ok?[/right]
[left]I’m so sorry Em. She never woke up. Last night she just...slipped by.[/left]
[right]No…no, that can’t be right.[/right]
[left]There was nothing anyone could do. Her body just…stopped fighting. It was like she’d decided to move on.[/left]
[right]It’s my fault. It’s all my fault.[/right]
[left]Don’t blame yourself. It was a mistake. You would have done everything you could if you’d known.[/left]
[right]No, you don’t understand! I did know! I could have woken her up! If I’d said the right thing, if I’d just gotten her to listen to me…![/right]
[left]What are you talking about?[/left]
[right]I saw her! She was right there, in front of me. All I needed to do was reach out, but I failed.[/right]
[left]Emily, this doesn’t make any sense?[/left]
[right]Just let her be dear. She needs time.[/right]
[left]It should have been me.[/left]
[right]It should have been me.[/right]
[left]It should have been me.[/left]

[left]You got the Imposter Ending[/left]",

	3: "[left]They said it was a matter of minutes.[/left]
[right]Dad? Is that you?[/right]
[left]Don’t say that. You’ll only make it worse.[/left]
[right]Mom? I’m here. It’s me, Emily.[/right]
[left]I’m sorry. I just-I feel like I could have done something. She was so close. Now she’s gone.[/left]
[right]No I’m not! I’m right here. Why can’t you hear me?[/right]
[left]I know. If only we’d noticed her slip away. Or if we’d thought to look by that bridge sooner. It was her favorite hiding spot. We should have remembered.[/left]
[right]The bridge...I remember now. I always went to the bridge when I wanted to be alone.[/right]
[left]She must have fallen asleep. She hadn’t slept in days. She was so distraught over Agnes.[/left]
[right]Agnes. Where’s Agnes? Is she ok?[/right]
[left]Hush dear. Agnes, darling, what is it? You should be in bed.[/left]

[right]Are you talking about Emily?[/right]
[left]Agnes! Oh thank god![/left]
[right]Yes dear, but you shouldn’t worry about it.[/right]

[left]She saved me.[/left]

[right]Huh?[/right]

[left]When I was asleep. She found me.[/left]

[right]What are you talking about sweetie?[/right]

[left]I was in a big, dark place. I was scared. She made me feel safe. I followed her voice to the light. And then I woke up. She saved me.[/left]

[right]That was just a dream darling.[/right]

[left]I know. But it was a real dream.[/left]

[right]Oh honey, come here. You know your sister loved you very much, right?[/right]

[left]Yeah. She told me.[/left]
[right]That’s right. Now let’s get you back to bed.[/right]

[left]Ok. Goodnight.[/left]
[right]Goodnight Agnes. I’m sorry I wasn’t there for you more. But at least you’re safe. I’ll miss you so much. Don’t forget me.[/right]

[left]I’m ready to go.[/left]

[left]You got the Silent Ending[/left]",

	4: "[left]Where am I? What happened? I was about to get out. Did I make it? I remember now: I was on the bridge, I must have fallen asleep. I need to wake up! I need to wake up to call for help. Help! Help! Is anyone there? Anyone?[/left]
[right]Watchman: No. Just me.[/right]
[left]Watchman. You’ve got to help me! I need to get back.[/left]
[right]Watchman: You’re too late.[/right]
[left]What? No, I can’t be! I was right there![/left]
[right]Watchman: You knew the risks. You had a chance to move on, to passBeyond. But you chose to cling on, to try to undo your mistakes. Now your opportunity has passed. Your body is long dead. You have no more home on the Earth.[/right]
[left]Fine. I don’t care. Just tell me this: is Agnes ok?[/left]
[right]Watchman: …[/right]
[left]I need to know![/left]
[right]Watchman: She was in a coma for four days. On the night you slipped away, she passed in her sleep.[/right]
[left]No…[/left]
[right]Watchman: You do not need to think of her anymore. She is in the Haven now.[/right]
[left]Could I have saved her?[/left]
[right]Watchman: It is hard to tell. Strange things can happen in between your world and Beyond.[/right]
[left]Will I ever see her again?[/left]
[right]Watchman: No. The Haven is destroyed, at least for you. The gate Beyond has been sealed.[/right]
[left]So where do I go?[/left]
[right]Watchman: Nowhere. You must stay here, with me.[/right]
[left]What will happen to me?[/left]
[right]Watchman: You will become used to the dark. You will feel pain, and regret, and guilt, but they will slowly fade. Your memories will dull and wither away, then your thoughts. Eventually, you will fade as well. You will become one with the Darkness. Perhaps you will become like me. Perhaps you will become Nothing. Only time will tell.[/right]"
}

@onready var label: RichTextLabel = $ScrollContainer/Label
@onready var scroll: ScrollContainer = $ScrollContainer
@onready var overlay: ColorRect = $FadeOverlay

var _scrolling: bool = false
var _done: bool = false
var _fade_timer: float = 0.0

func _ready() -> void:
	overlay.modulate.a = 0.0
	label.text = ENDINGS.get(ending_id, "")
	await get_tree().create_timer(1.0).timeout
	_scrolling = true

func _process(delta: float) -> void:
	if _scrolling and not _done:
		scroll.scroll_vertical += int(scroll_speed * delta)
		# Check if reached the bottom
		var max_scroll := scroll.get_v_scroll_bar().max_value - scroll.size.y
		if scroll.scroll_vertical >= max_scroll:
			_scrolling = false
			_done = true

	if _done:
		_fade_timer += delta
		overlay.modulate.a = clamp(_fade_timer / fade_duration, 0.0, 1.0)
		if _fade_timer >= fade_duration:
			get_tree().quit()  # or change scene: get_tree().change_scene_to_file("res://main.tscn")
