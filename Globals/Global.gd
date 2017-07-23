extends Node

var seeder = []
var player_pos = Vector2(0, 0)
var checkpoint = Vector2(0, 0)
var checks = {
	"TutorialIntro": false,
	"TutorialLifeforce": false,
	"1BossDead": false,
	"1ArenaBeat": false,
	"1Classmate": false,
	"StrongSlash": false,
	"AttackSpeedUpgrade": false,
	"1ShieldUpgrade": false,
	"2ShieldUpgrade": false,
	"3ShieldUpgrade": false,
}
var total_score = 0
var total_coins = 0
