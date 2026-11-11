-- Phase 2: real translated content for The Arcway, extracted from Zygor's
-- guide (Guides/Dungeons/ZygorDungeonAllianceLEGION.lua, "The Arcway" entry)
-- and translated to Russian. Each role's text is the common ("_EVERYONE:_")
-- tips plus that role's own tips folded in, so it reads as one complete
-- block rather than a diff against a baseline.
--
-- Proper nouns (dungeon/boss names) are my own transliteration, not pulled
-- from an official Blizzard RU string table (none was available to check
-- against) - if any of them don't match what the RU client actually shows,
-- it's a one-line fix in this file, not a structural issue.
local instance = GITGUD.RegisterInstance(1079, "Аркона", "dungeon")

local xakal = GITGUD.AddBoss(instance, "Генерал Ксакал", 98206)
local xakal_common =
	"• Уходите с линии атаки, если на вас наложена метка Теневого Рассечения.\n" ..
	"• Избегайте зелёных кругов Прорех Скверны на полу.\n" ..
	"• От Свирепого Удара вас отбрасывает назад — следите, чтобы не приземлиться в зелёный круг."
GITGUD.SetBossText(xakal, "normal", "tank",
	xakal_common .. "\n• Обязательно тауньте феломышей (Dread Felbats), которые появляются по ходу боя.")
GITGUD.SetBossText(xakal, "normal", "healer",
	xakal_common .. "\n• Будьте готовы к большим хилам после каста Свирепого Удара.")
GITGUD.SetBossText(xakal, "normal", "dps", xakal_common)

local naltira = GITGUD.AddBoss(instance, "Нал'тира", 98207)
local naltira_common =
	"• Если вас с кем-то связало Спутывающей Паутиной — разбегитесь в стороны, чтобы разорвать связь.\n" ..
	"• Избегайте жёлтых пятен на полу.\n" ..
	"• Уходите с места, если на вас нацелены Мерцающие Удары."
GITGUD.SetBossText(naltira, "normal", "tank", naltira_common)
GITGUD.SetBossText(naltira, "normal", "healer",
	naltira_common .. "\n• Готовьтесь к большим хилам после каста Временного Смещения.")
GITGUD.SetBossText(naltira, "normal", "dps", naltira_common)

local corstilax = GITGUD.AddBoss(instance, "Корстилакс", 98205)
local corstilax_common =
	"• Кликайте по большому кристаллу, который появляется у игроков под Карантином, чтобы освободить их.\n" ..
	"• Избегайте кружащихся кругов на полу во время каста Протокола Подавления.\n" ..
	"• Заходите в фиолетовые пятна Энергии Колодца — они дают стакающееся ускорение +15%.\n" ..
	"• Бегите НА Очищающую Силу — после каста идёт взрыв по площади с тяжёлым уроном.\n" ..
	"• Очищающая Сила снимает стаки ускорения от Энергии Колодца. Если к моменту взрыва у вас остались стаки — вас оглушит."
GITGUD.SetBossText(corstilax, "normal", "tank", corstilax_common)
GITGUD.SetBossText(corstilax, "normal", "healer",
	corstilax_common .. "\n• Будьте начеку во время Протокола Подавления — группа может получить много урона.")
GITGUD.SetBossText(corstilax, "normal", "dps", corstilax_common)

local ivanyr = GITGUD.AddBoss(instance, "Иваньир", 98203)
local ivanyr_common =
	"• Отходите от других игроков, если на вас наложена Нестабильная Магия.\n" ..
	"• Бегите друг к другу, если вас выбрало Связью Эфира.\n" ..
	"• Пространство между игроками, связанными Связью Эфира, после её спадания превращается в зону урона на полу."
GITGUD.SetBossText(ivanyr, "normal", "tank", ivanyr_common)
GITGUD.SetBossText(ivanyr, "normal", "healer",
	ivanyr_common .. "\n• Готовьтесь к хилам после каста Нестабильной Магии — бьёт сильно по цели и союзникам рядом, когда эффект спадает.")
GITGUD.SetBossText(ivanyr, "normal", "dps",
	ivanyr_common .. "\n• Прерывайте его, когда он начинает каст Перегрузки Маной.")

local vandros = GITGUD.AddBoss(instance, "Советник Вандрос", 98208)
local vandros_common =
	"• Избегайте синих плавающих Хроно-осколков — взрываются через 8 секунд.\n" ..
	"• Избегайте фиолетовых шаров Силовых Бомб — они взрываются.\n" ..
	"• Пробегайте сквозь ударные волны после взрыва Силовых Бомб.\n" ..
	"• Посреди боя вас телепортирует в сторону, когда он кастует Изгнание во Времени.\n" ..
	"• Место телепортации случайное — вернитесь к боссу за 2 минуты, иначе умрёте."
GITGUD.SetBossText(vandros, "normal", "tank", vandros_common)
GITGUD.SetBossText(vandros, "normal", "healer",
	vandros_common .. "\n• Готовьтесь к хилам после каста Силовых Бомб — может нанести серьёзный урон всей группе.")
GITGUD.SetBossText(vandros, "normal", "dps",
	vandros_common .. "\n• Обязательно прерывайте Ускоряющийся Разряд как можно чаще.")
