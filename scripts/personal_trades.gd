extends RefCounted

const ITEMS := ["coin", "riverfish", "provision"]
const NAMES := {"coin": "coin", "riverfish": "riverfish", "provision": "trail provisions"}
const REACH := 3.0
var offers: Dictionary = {}
var messages: Dictionary = {}
var next_id := 1


func for_player(token: String) -> Dictionary:
	for offer: Dictionary in offers.values():
		if token == offer["from"] or token == offer["to"]:
			return offer
	return {}


func _valid(offer: Dictionary, context: Dictionary) -> bool:
	var a: String = offer["from"]
	var b: String = offer["to"]
	var positions: Dictionary = context["positions"]
	if a == b or a not in context["active"] or b not in context["active"] or not positions.has(a) or not positions.has(b):
		return false
	if bool(context["downed"].get(a, false)) or bool(context["downed"].get(b, false)) or positions[a].distance_to(positions[b]) > REACH:
		return false
	return int(context["holdings"][offer["give"]].get(a, 0)) >= int(offer["give_count"]) and int(context["holdings"][offer["take"]].get(b, 0)) >= int(offer["take_count"])


func command(token: String, request: Dictionary, context: Dictionary) -> bool:
	tick(0, context)
	if token not in context["active"]:
		return false
	var action := str(request.get("action", ""))
	if action == "propose":
		var target := str(request.get("to", ""))
		var give := str(request.get("give", ""))
		var take := str(request.get("take", ""))
		if not request.get("give_count") is int or not request.get("take_count") is int:
			return false
		var give_count := int(request["give_count"])
		var take_count := int(request["take_count"])
		if give not in ITEMS or take not in ITEMS or give == take or give_count < 1 or give_count > 99 or take_count < 1 or take_count > 99:
			messages[token] = "Choose two different personal goods and quantities from 1 to 99."
			return false
		if not for_player(token).is_empty() or not for_player(target).is_empty():
			messages[token] = "One of you already has an offer. Cancel it before proposing new terms."
			return false
		var offer := {"id": next_id, "from": token, "to": target, "give": give, "give_count": give_count, "take": take, "take_count": take_count, "remaining": 60.0}
		if not _valid(offer, context):
			messages[token] = "Both players must be nearby, standing and carrying the offered goods."
			return false
		offers[next_id] = offer
		next_id += 1
		messages[token] = "Offer sent. Nothing moves until your companion accepts."
		messages[target] = "Trade offer received. Review the exact terms before accepting."
		return false
	if not request.get("id") is int:
		return false
	var id := int(request["id"])
	if not offers.has(id):
		return false
	var offer: Dictionary = offers[id]
	if token != offer["from"] and token != offer["to"]:
		return false
	if action == "cancel":
		_finish(id, "Offer cancelled. No goods moved.")
		return false
	if action != "accept" or token != offer["to"]:
		return false
	# Validation and all four balance updates execute synchronously on the authority.
	if not _valid(offer, context):
		_finish(id, "Offer is no longer valid. No goods moved.")
		return false
	var offered: Dictionary = context["holdings"][offer["give"]]
	var requested: Dictionary = context["holdings"][offer["take"]]
	var a: String = offer["from"]
	var b: String = offer["to"]
	offered[a] = int(offered.get(a, 0)) - int(offer["give_count"])
	offered[b] = int(offered.get(b, 0)) + int(offer["give_count"])
	requested[b] = int(requested.get(b, 0)) - int(offer["take_count"])
	requested[a] = int(requested.get(a, 0)) + int(offer["take_count"])
	_finish(id, "Trade completed. Your new balances are saved.")
	return true


func tick(delta: float, context: Dictionary) -> void:
	for id: int in offers.keys():
		var offer: Dictionary = offers[id]
		offer["remaining"] = maxf(0, float(offer["remaining"]) - maxf(0, delta))
		if not _valid(offer, context) or offer["remaining"] <= 0:
			_finish(id, "Offer expired or conditions changed. No goods moved.")


func cancel_player(token: String) -> void:
	var offer := for_player(token)
	if not offer.is_empty():
		_finish(int(offer["id"]), "Companion left. No goods moved.")


func _finish(id: int, message: String) -> void:
	var offer: Dictionary = offers[id]
	messages[offer["from"]] = message
	messages[offer["to"]] = message
	offers.erase(id)


func snapshot() -> Dictionary:
	return {"offers": offers.duplicate(true), "messages": messages.duplicate()}
