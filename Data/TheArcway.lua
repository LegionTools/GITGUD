-- Real translated content for The Arcway, extracted from Zygor's guide
-- (Guides/Dungeons/ZygorDungeonAllianceLEGION.lua, "The Arcway" entry) and
-- translated to Russian. Zygor tags its tips "_EVERYONE:_" (shown to the
-- whole group, stored under the "everyone" pseudo-role key) and
-- "_TANK:_"/"_HEALER:_"/"_DAMAGE:_" (role-specific additions on top of
-- that) - kept as two separate blocks here rather than folding everyone's
-- text into each role's string three times over; the UI shows "everyone"
-- above the selected role's own text. A boss with no addition for a given
-- role (e.g. no _TANK:_ line in Zygor's data) simply has no SetBossText
-- call for that role - the UI falls back to "no extra tip for this role".
--
-- Proper nouns (dungeon/boss names) are my own transliteration, not pulled
-- from an official Blizzard RU string table (none was available to check
-- against) - if any of them don't match what the RU client actually shows,
-- it's a one-line fix in this file, not a structural issue.
local instance = GITGUD.RegisterInstance(1079, "Аркона", "dungeon")

local xakal = GITGUD.AddBoss(instance, "Генерал Ксакал", 98206)
GITGUD.SetBossText(xakal, "normal", "everyone",
	"• Уходите с линии атаки, если на вас наложена метка Теневого Рассечения.\n" ..
	"• Избегайте зелёных кругов Прорех Скверны на полу.\n" ..
	"• От Свирепого Удара вас отбрасывает назад — следите, чтобы не приземлиться в зелёный круг.")
GITGUD.SetBossText(xakal, "normal", "tank", "Обязательно тауньте феломышей (Dread Felbats), которые появляются по ходу боя.")
GITGUD.SetBossText(xakal, "normal", "healer", "Будьте готовы к большим хилам после каста Свирепого Удара.")

local naltira = GITGUD.AddBoss(instance, "Нал'тира", 98207)
GITGUD.SetBossText(naltira, "normal", "everyone",
	"• Если вас с кем-то связало Спутывающей Паутиной — разбегитесь в стороны, чтобы разорвать связь.\n" ..
	"• Избегайте жёлтых пятен на полу.\n" ..
	"• Уходите с места, если на вас нацелены Мерцающие Удары.")
GITGUD.SetBossText(naltira, "normal", "healer", "Готовьтесь к большим хилам после каста Временного Смещения.")

local corstilax = GITGUD.AddBoss(instance, "Корстилакс", 98205)
GITGUD.SetBossText(corstilax, "normal", "everyone",
	"• Кликайте по большому кристаллу, который появляется у игроков под Карантином, чтобы освободить их.\n" ..
	"• Избегайте кружащихся кругов на полу во время каста Протокола Подавления.\n" ..
	"• Заходите в фиолетовые пятна Энергии Колодца — они дают стакающееся ускорение +15%.\n" ..
	"• Бегите НА Очищающую Силу — после каста идёт взрыв по площади с тяжёлым уроном.\n" ..
	"• Очищающая Сила снимает стаки ускорения от Энергии Колодца. Если к моменту взрыва у вас остались стаки — вас оглушит.")
GITGUD.SetBossText(corstilax, "normal", "healer", "Будьте начеку во время Протокола Подавления — группа может получить много урона.")

local ivanyr = GITGUD.AddBoss(instance, "Иваньир", 98203)
GITGUD.SetBossText(ivanyr, "normal", "everyone",
	"• Отходите от других игроков, если на вас наложена Нестабильная Магия.\n" ..
	"• Бегите друг к другу, если вас выбрало Связью Эфира.\n" ..
	"• Пространство между игроками, связанными Связью Эфира, после её спадания превращается в зону урона на полу.")
GITGUD.SetBossText(ivanyr, "normal", "healer",
	"Готовьтесь к хилам после каста Нестабильной Магии — бьёт сильно по цели и союзникам рядом, когда эффект спадает.")
GITGUD.SetBossText(ivanyr, "normal", "dps", "Прерывайте его, когда он начинает каст Перегрузки Маной.")

local vandros = GITGUD.AddBoss(instance, "Советник Вандрос", 98208)
GITGUD.SetBossText(vandros, "normal", "everyone",
	"• Избегайте синих плавающих Хроно-осколков — взрываются через 8 секунд.\n" ..
	"• Избегайте фиолетовых шаров Силовых Бомб — они взрываются.\n" ..
	"• Пробегайте сквозь ударные волны после взрыва Силовых Бомб.\n" ..
	"• Посреди боя вас телепортирует в сторону, когда он кастует Изгнание во Времени.\n" ..
	"• Место телепортации случайное — вернитесь к боссу за 2 минуты, иначе умрёте.")
GITGUD.SetBossText(vandros, "normal", "healer", "Готовьтесь к хилам после каста Силовых Бомб — может нанести серьёзный урон всей группе.")
GITGUD.SetBossText(vandros, "normal", "dps", "Обязательно прерывайте Ускоряющийся Разряд как можно чаще.")
