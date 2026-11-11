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
-- Dungeon name confirmed live by the user playing on the RU client:
-- "Катакомбы Сурамара" (not my earlier transliterated guess "Аркона").
-- Boss names below are still my own transliteration, unconfirmed.
--
-- Map ID 1516 (NOT Zygor's own mapid=1079 for this guide - confirmed via
-- /gitguddebug live and cross-checked against BigWigs/Loader.lua, see the
-- big comment in Registry.lua for why those two IDs differ).
--
-- bigwigsModule values and the spell IDs in the <a href="spell:ID"> links
-- below are both copied directly from this server's own installed dungeon
-- boss modules (LittleWigs/Legion/TheArcway/*.lua - a custom server-side
-- BigWigs build that bundles dungeon content directly under LittleWigs/
-- rather than a separate LittleWigs_Legion addon; Registry.lua's comment
-- about no dungeon modules existing was wrong, corrected there too). Not
-- every mentioned ability had a confirmed real spellID to link (Nal'tira's
-- "Blink Strikes" is tracked by an Encounter-Journal section ID, not a
-- real spell ID, and "Temporal Displacement" isn't tracked by this module
-- at all) - left as plain text rather than guessing an ID.
local instance = GITGUD.RegisterInstance(1516, "Катакомбы Сурамара", "dungeon")

local xakal = GITGUD.AddBoss(instance, "Генерал Ксакал", 98206, "General Xakal")
GITGUD.SetBossText(xakal, "normal", "everyone",
	"• Уходите с линии атаки, если на вас наложена метка <a href=\"spell:212030\">Теневого Рассечения</a>.\n" ..
	"• Избегайте зелёных кругов <a href=\"spell:197776\">Прорех Скверны</a> на полу.\n" ..
	"• От <a href=\"spell:197810\">Свирепого Удара</a> вас отбрасывает назад — следите, чтобы не приземлиться в зелёный круг.")
GITGUD.SetBossText(xakal, "normal", "tank", "Обязательно тауньте феломышей (Dread Felbats), которые появляются по ходу боя.")
GITGUD.SetBossText(xakal, "normal", "healer", "Будьте готовы к большим хилам после каста Свирепого Удара.")

local naltira = GITGUD.AddBoss(instance, "Нал'тира", 98207, "Naltira")
GITGUD.SetBossText(naltira, "normal", "everyone",
	"• Если вас с кем-то связало <a href=\"spell:200284\">Спутывающей Паутиной</a> — разбегитесь в стороны, чтобы разорвать связь.\n" ..
	"• Избегайте жёлтых пятен на полу.\n" ..
	"• Уходите с места, если на вас нацелены Мерцающие Удары.")
GITGUD.SetBossText(naltira, "normal", "healer", "Готовьтесь к большим хилам после каста Временного Смещения.")

local corstilax = GITGUD.AddBoss(instance, "Корстилакс", 98205, "Corstilax")
GITGUD.SetBossText(corstilax, "normal", "everyone",
	"• Кликайте по большому кристаллу, который появляется у игроков под <a href=\"spell:195804\">Карантином</a>, чтобы освободить их.\n" ..
	"• Избегайте кружащихся кругов на полу во время каста <a href=\"spell:196068\">Протокола Подавления</a>.\n" ..
	"• Заходите в фиолетовые пятна Энергии Колодца — они дают стакающееся ускорение +15%.\n" ..
	"• Бегите НА <a href=\"spell:196115\">Очищающую Силу</a> — после каста идёт взрыв по площади с тяжёлым уроном.\n" ..
	"• Очищающая Сила снимает стаки ускорения от Энергии Колодца. Если к моменту взрыва у вас остались стаки — вас оглушит.")
GITGUD.SetBossText(corstilax, "normal", "healer", "Будьте начеку во время Протокола Подавления — группа может получить много урона.")

local ivanyr = GITGUD.AddBoss(instance, "Иваньир", 98203, "Ivanyr")
GITGUD.SetBossText(ivanyr, "normal", "everyone",
	"• Отходите от других игроков, если на вас наложена <a href=\"spell:196562\">Нестабильная Магия</a>.\n" ..
	"• Бегите друг к другу, если вас выбрало <a href=\"spell:196805\">Связью Эфира</a>.\n" ..
	"• Пространство между игроками, связанными Связью Эфира, после её спадания превращается в зону урона на полу.")
GITGUD.SetBossText(ivanyr, "normal", "healer",
	"Готовьтесь к хилам после каста Нестабильной Магии — бьёт сильно по цели и союзникам рядом, когда эффект спадает.")
GITGUD.SetBossText(ivanyr, "normal", "dps", "Прерывайте его, когда он начинает каст <a href=\"spell:196392\">Перегрузки Маной</a>.")

local vandros = GITGUD.AddBoss(instance, "Советник Вандрос", 98208, "Advisor Vandros")
GITGUD.SetBossText(vandros, "normal", "everyone",
	"• Избегайте синих плавающих <a href=\"spell:203881\">Хроно-осколков</a> — взрываются через 8 секунд.\n" ..
	"• Избегайте фиолетовых шаров <a href=\"spell:202974\">Силовых Бомб</a> — они взрываются.\n" ..
	"• Пробегайте сквозь ударные волны после взрыва Силовых Бомб.\n" ..
	"• Посреди боя вас телепортирует в сторону, когда он кастует <a href=\"spell:203882\">Изгнание во Времени</a>.\n" ..
	"• Место телепортации случайное — вернитесь к боссу за 2 минуты, иначе умрёте.")
GITGUD.SetBossText(vandros, "normal", "healer", "Готовьтесь к хилам после каста Силовых Бомб — может нанести серьёзный урон всей группе.")
GITGUD.SetBossText(vandros, "normal", "dps", "Обязательно прерывайте <a href=\"spell:203176\">Ускоряющийся Разряд</a> как можно чаще.")
