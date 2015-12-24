--[[
 
	Blue Balls(°□°） v1.0
	by CoreLogic 12/23/2015
	
	<b>[What is it?]</b>
	A wonky new mod from the creator of Dank Souls and Flip All The Things!. <i>Blue Balls</i>, a new mini-game where NPCs spawn yoga balls players can collect to score!
	

	<b>[How to play]</b>
	Hunt NPCs and collect blue balls they drop. It's that simple. 


	<b>[Game modes]</b>

	1) Go! : invincible, good load-out, unending fun. Hit spacebar to end game.
	2) Timed : invicible, good loud-out, how many balls can you get before the timer runs out?

	
	<b>[Rules]</b>

	1) Dead NPCs will spawn blue balls.
	2) Players can walk over balls to pick up and score.
	3) Balls spawn under force in the direction the NPC is looking at time of death.
	4) Headshots mostly bring balls directly to the player, see rule #3
	5) Wounded NPCs spawn multiple blue balls.
	6) Some random balls are trolls you can't pick-up. 


	<b>[Tips: how do I get the most Blue Balls?]</b>

	- Balls spawn under force in the direction the NPC is looking at time of death.
	- Cars, bullets, walls any hard object will burst you balls on hard impact. 
	- Shooting a cop behind car door/cover will burst your ball, <i>strafing is required</i>.
	- Since fire, exposions will burst balls, grenades and other bombs should be regulated to flushing cops away from cover by deploying to one side, instead of attacking with them directly.
	- Remember, if you hit an NPC with enough force to kill on impact, you can also score points while 

	driving without leaving the car!
	- Players have to be low to the ground to score when driving, trucks therefore will not work.


	<b>[Background]</b>
	Like others I have created, this game came out of the idea of Rings bursting out in Sonic the Hedgehog when he would get hurt/die, and collecting power-ups in Sinistar (an ancient arcade game). The mechanics are reused from Flip All The Things with added game rules and UI elements. 

		
	Enjoy!
	
	
	<b>[Weapons]</b>
	WEAPON_PISTOL
	WEAPON_COMBATPISTOL
	WEAPON_CARBINERIFLE
	WEAPON_ASSAULTSHOTGUN
	WEAPON_PROXMINE
	WEAPON_MOLOTOV
	WEAPON_RPG
	WEAPON_MINIGUN
	WEAPON_KNIFE
	WEAPON_HAMMER
	WEAPON_GOLFCLUB
	WEAPON_MICROSMG
	WEAPON_ASSAULTSMG
	WEAPON_ADVANCEDRIFLE
	WEAPON_COMBATMG
	WEAPON_PUMPSHOTGUN
	WEAPON_SAWNOFFSHOTGUN
	WEAPON_BULLPUPSHOTGUN
	WEAPON_HEAVYSNIPER
	WEAPON_GRENADELAUNCHER
	WEAPON_SMOKEGRENADE
	WEAPON_DAGGER
	WEAPON_HATCHET
	WEAPON_HEAVYSHOTGUN
	WEAPON_MARKSMANRIFLE
	
]]--	
local BB = {};
BB.settings = {};
-- ==================================================
-- ==================================================
-- ===== PLAYER SETTINGS ============================
-- ==================================================
-- ===== Timers =====================================
BB.settings["game_timer_delay"] = 10000; 	-- Game mode #2: countdown timer delay
BB.settings["start_msg_delay"] = 500;		-- How long game start up help message is shown on screen 
BB.settings["hit_msg_delay"] = 60;			-- Time a hit is shown on screen 
-- ===== Key bindings ===============================
BB.settings["key_start"]=46; 				-- Start/Stop mod key ('del')
BB.settings["key_one"]=49;					-- Game mode #1: Invincible ('1')
BB.settings["key_two"]=50;					-- Game mode #2: HardCore   ('2')
BB.settings["key_space"]=32;				-- End game key	
-- ===== Config Game Settings =======================
BB.settings["cops_ignore"] = false;			-- Cops will show up when false
BB.settings["max_objects"] = 200;			-- Slower machines should use a lower number (will delete all objects when this is reached or could crash game when too many)
BB.settings["touch_msg"] = "+";				-- Msg shown onscreen when player touches ball (scores)
-- ===== Config Force (may alter gameplay!)==========
BB.settings["force_height"] = 8;			-- Height objects will be flipped
BB.settings["force_pos_x"] = 1;				-- Direction they will be flipped on x axis
BB.settings["force_pos_y"] = 1;				-- Direction they will be flipped on y axis
-- ==================================================
-- ==================================================
-- ===== EDIT BELOW AT OWN RISK! ====================
-- ==================================================
-- ==================================================
BB.data = {};
BB.data["version"] = "1.0";
BB.data["seenPeds"] = {};
BB.data["seenPedSkins"] = {};
BB.data["blips"] = {};
BB.data["deadPeds"] = {};
BB.data["objects"] = {};
BB.data["bad_coords"] = 0;
BB.data["dead_count"] = 0;
BB.data["playGame"] = false;
BB.data["game_mode"] = 0;
BB.data["touched"] = {}
BB.data["score"] = 0;
BB.data["game_over"] = false;
-- === Toggles ======================================
BB.toggle = {};
BB.toggle["game_scanner"] = true;
BB.toggle["touched"] = false;
BB.toggle["spawn_dialog"] = false;
BB.timer={};
BB.timer["touched"] = BB.settings["hit_msg_delay"];
BB.timer["game_timer"] = BB.settings["game_timer_delay"];
BB.timer["spawn_timer"] = BB.settings["start_msg_delay"];
-- ==================================================
-- ==================================================
-- ======   *   =====================   *   =========
-- ==================================================
-- ==================  ][    ][  ====================
-- ==================================================
function BB.playSound()
	AUDIO.PLAY_SOUND_FRONTEND(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true);
end
function BB.drawText(text, x, y, scale, center, font, r, g, b)
	UI.SET_TEXT_FONT(font);
	UI.SET_TEXT_SCALE(scale, scale);
	UI.SET_TEXT_COLOUR(r, g, b, 255);
	UI.SET_TEXT_WRAP(0.0, 1.0);
	UI.SET_TEXT_CENTRE(center);
	UI.SET_TEXT_EDGE(2, 255, 255, 255, 205);
	UI._SET_TEXT_ENTRY("STRING");
	UI.SET_TEXT_DROPSHADOW(2, 0, 0, 0, 205);
	UI._ADD_TEXT_COMPONENT_STRING(text);
	UI._DRAW_TEXT(y, x);
end
function BB.giveBunchWeapons()
		local playerPed = PLAYER.PLAYER_PED_ID();
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_PISTOL"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_COMBATPISTOL"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_CARBINERIFLE"), 500, true);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_ASSAULTSHOTGUN"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_PROXMINE"), 1000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_MOLOTOV"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_RPG"), 1050, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_MINIGUN"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_KNIFE"),1, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_HAMMER"), 1, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_GOLFCLUB"), 1, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_MICROSMG"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_ASSAULTSMG"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_ADVANCEDRIFLE"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_COMBATMG"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_PUMPSHOTGUN"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_SAWNOFFSHOTGUN"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_BULLPUPSHOTGUN"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_HEAVYSNIPER"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_GRENADELAUNCHER"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_SMOKEGRENADE"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_DAGGER"), 1, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_HATCHET"), 1, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_HEAVYSHOTGUN"), 2000, false);
		WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, GAMEPLAY.GET_HASH_KEY("WEAPON_MARKSMANRIFLE"), 2000, false);
end
-- keep track of unique peds (seenPeds) table
function BB.newPedScanner()
	local playerPed = PLAYER.PLAYER_PED_ID();
	local PedTab,PedCount = PED.GET_PED_NEARBY_PEDS(playerPed, 1, 1);
	for k,thisPed in ipairs(PedTab)do
		if(thisPed == playerPed)then
		else
			if (BB.isNewPed(thisPed)) then
				local skin =  ENTITY.GET_ENTITY_MODEL(thisPed);
				table.insert(BB.data["seenPeds"],thisPed);
				table.insert(BB.data["seenPedSkins"],skin);
				print("New ped:"..thisPed);
			end
		end
	end
end
-- return if ped is in list
function BB.isNewPed(ped)
	for i=1,#BB.data["seenPeds"] do
		if(BB.data["seenPeds"][i] == ped) then
			return false;
		end
	end
	return true;
end
-- using seenPeds, find dead peds and spawn objects
function BB.updatecheck()
	for i=1,#BB.data["seenPeds"] do
		local thisPed = BB.data["seenPeds"][i];
		if (thisPed ~= nil) then
			local coord = ENTITY.GET_ENTITY_COORDS(thisPed, false);
			if (coord.x == 0)then
				BB.data["bad_coords"] = BB.data["bad_coords"] + 1;
			else
				local dead = ENTITY.IS_ENTITY_DEAD(thisPed);
				local health = ENTITY.GET_ENTITY_HEALTH(thisPed);
				if(health > 0) then
				
				elseif(health == 0) then
					if (dead) then
						--BB.applyForcePed(thisPed);	
						table.insert(BB.data["deadPeds"],thisPed);
						BB.data["seenPeds"][i] = nil;
						--PED.DELETE_PED(thisPed);
						BB.spawnDeathObjects(coord.x,coord.y,coord.z, false);
					end
				end
			end
		end
	end
end
function BB.spawnDeathObjects(x,y,z)
	--for i=1,3 do
		local obj = BB.spawnObject("prop_swiss_ball_01",x,y,z);
		BB.applyForce(obj);	
	--end
end
function BB.spawnObject(modelName, x, y, z)
		model = GAMEPLAY.GET_HASH_KEY(modelName);
		print("Spawn object:"..modelName);
		STREAMING.REQUEST_MODEL(model)
		while(not STREAMING.HAS_MODEL_LOADED(model)) do
			wait(1)
		end
		obj = OBJECT.CREATE_OBJECT(model, x, y, z, true, false, true);
		table.insert(BB.data["objects"],obj);
		OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(obj);
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model);
		ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(obj);
		return obj;
end
function BB.applyForcePed(e)
	print("Apply force PED:"..e);
	ENTITY.SET_ENTITY_VELOCITY(e, 1,1, 10);
end
function BB.applyForce(entity)
	local force = 150;
	local playerCoord = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0);
	local coord=ENTITY.GET_ENTITY_COORDS(entity,true)
	local dx=coord.x - playerCoord.x
	local dy=coord.y - playerCoord.y
	local dz=coord.z - playerCoord.z
	local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
	local distanceRate=(force/distance)*math.pow(1.04,1-distance)
	ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, distanceRate-dx,distanceRate-dy,distanceRate-dz, math.random()*math.random(-1,1),math.random()*math.random(-1,1),math.random()*math.random(-1,1), true, false, true, true, true, true)
end
function BB.spawnVeh(modelName) 
	local skin = GAMEPLAY.GET_HASH_KEY(modelName);
	local playerPed = PLAYER.PLAYER_PED_ID();
	local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(playerPed, 0.0, 25.0, 2.0);
	STREAMING.REQUEST_MODEL(skin)
	while(not STREAMING.HAS_MODEL_LOADED(skin)) do
		wait(1)
	end
	local v = VEHICLE.CREATE_VEHICLE(skin, coorBB.x, coorBB.y, coorBB.z, ENTITY.GET_ENTITY_HEADING(playerPed), false,false);
	table.insert(BB.data["vehicles"],v);
	STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(skin);
end
function BB.setupGame()
	print("Flip All The Things v"..BB.data["version"].." by CoreLogic");
	-- let's initialize the wave counter delay (how long between Dank spawns) setting to the current level
	BB.data["setup"] = true;
	BB.data["game_over"] = false;
	BB.toggle["game_scanner"] = true;
end
-- start/stop game key action handler
function BB.startkey_action_handler()
	print("del key press");
	if (BB.data["playGame"]) then
		print("playGame now false");
		BB.data["playGame"] = false;
		BB.data["setup"] = false;
		BB.timer["touched"] = BB.settings["hit_msg_delay"];
		BB.toggle["touched"]=false;

	else
		BB.data["playGame"] = true;
		print("playGame now true");
		BB.giveBunchWeapons();
		BB.timer["touched"] = BB.settings["hit_msg_delay"];
		BB.toggle["touched"]=false;
		BB.data["game_mode"]=0;
		BB.data["touched"] = {}
		BB.data["score"] = 0;
	end
	BB.cleanAll();
	BB.setupGame();
end
-- did player touch a blue ball?
function BB.checkYoga()
	for i=1, #BB.data["objects"] do
	    local ball = BB.data["objects"][i];
		if (ball ~= nil) then
			if(ENTITY.IS_ENTITY_TOUCHING_ENTITY(PLAYER.PLAYER_PED_ID(), ball)) then
				BB.playSound();
				print("TOUCHED!:"..ball);
				table.insert(BB.data["touched"],ball);
				-- let's freeze the ball 
				--ENTITY.FREEZE_ENTITY_POSITION(ball, true);
				-- let's try and delete it
				--ENTITY.DELETE_ENTITY(ball);
				--OBJECT.DELETE_OBJECT(ball);
				-- Having issue removing balls correctly for some reason
				-- Instead let's simply remove them from view by placing in the sky
				local bcoord=ENTITY.GET_ENTITY_COORDS(ball, true);
				local dz = bcoord.z + 100;
				ENTITY.SET_ENTITY_COORDS(ball, bcoord.x, bcoord.y, dz, true, true, true, true);
				-- update game register data
				BB.data["objects"][i] = nil;
				BB.data["score"] = BB.data["score"] + 1;
				BB.toggle["touched"] = true;
				wait(20); -- blink UI when we pick up many at one time
			end
		end
	end
end
-- just DO IT!
function BB.tick()
	local player = PLAYER.PLAYER_ID() 
	local playerPed = PLAYER.PLAYER_PED_ID() 
	local deathcheck = PLAYER.IS_PLAYER_DEAD(player);
	PLAYER._SET_MOVE_SPEED_MULTIPLIER(playerPed, 99.25);
	ENTITY.SET_ENTITY_MAX_SPEED(playerPed, 100.0);
	ENTITY.SET_ENTITY_INVINCIBLE(playerPed, true);
	if (not BB.data["setup"]) then
		BB.setupGame();
	end
	if(BB.settings["cops_ignore"]) then
		PLAYER.SET_MAX_WANTED_LEVEL(0);
		PLAYER.CLEAR_PLAYER_WANTED_LEVEL(playerPed);
	else
		PLAYER.SET_MAX_WANTED_LEVEL(5);
	end	
	if(get_key_pressed(BB.settings["key_start"])) then --  del (start)
		BB.startkey_action_handler();
		wait(1000);
	end
	if(get_key_pressed(BB.settings["key_one"])) then -- "1"
		BB.data["game_mode"] = 1;
		BB.data["game_over"] = false;
		BB.data["game_scanner"] = true;
		print("Setting game mode 1");
		BB.toggle["spawn_dialog"] = true;
		BB.timer["spawn_timer"] = BB.settings["start_msg_delay"];
		wait(1000);
	end
	if(get_key_pressed(BB.settings["key_two"])) then -- "2"
		BB.data["game_mode"] = 2;
		print("Setting game mode 2");
		BB.timer["game_timer"] = 5000;
		BB.toggle["spawn_dialog"] = true;
		BB.timer["spawn_timer"] = BB.settings["start_msg_delay"];
		wait(1000);
	end
	if(get_key_pressed(BB.settings["key_space"])) then -- "space"
		print("Setting game to over");
		if(BB.data["game_mode"] == 1) then
			BB.gameOver();
			wait(1000);
		end
	end
	-- Game over hud
	-- =============
	if (BB.data["game_over"]) then
		--ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID() , true);
		BB.drawText("GAME OVER",  0.1, 0.49, 3.0, true, 1, 0, 0, 0);
		BB.drawText("Balls:          "..#BB.data["touched"], 0.31, 0.49, 2.0, true, 1, 255, 0, 0);
		local score = #BB.data["touched"] * 6;
		BB.drawText("Score:          "..score, 0.47, 0.49, 2.0, true, 1, 255, 0, 0);
		BB.drawText(" [del] to continue...", 0.74, 0.49, 0.26, true, 0, 255, 255, 0);
		
	end
	-- Play Game
	-- ==========
	if(not BB.data["playGame"]) then
		BB.drawText(" [del] Blue Balls! v"..BB.data["version"].." - by CoreLogic 2015", 0.80, 0.0005, 0.24, false, 0,  0, 0, 0);
		--ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID() , false);
	else
		if(BB.data["game_mode"] == 1) then
			BB.drawText(" [del] off - Blue Balls: GO!", 0.80, 0.0005, 0.24, false, 0,  0, 0, 0);
		elseif(BB.data["game_mode"] == 2) then
			BB.drawText(" [del] off - Blue Balls: Timed", 0.80, 0.0005, 0.24, false, 0, 255, 0, 0);
		--elseif(BB.data["game_mode"] == 3) then
		--	BB.drawText(" [del] off - HardCore", 0.80, 0.0005, 0.24, false, 0,  255, 255, 255);
		end
		ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID() , false);
	-- START
	-- =====
	-- test if player exists (and is not dead)
	-- =========================================
		local playerExists = ENTITY.DOES_ENTITY_EXIST(playerPed);
		if(playerExists and not deathcheck) then
			PLAYER._SET_MOVE_SPEED_MULTIPLIER(playerPed, 50.25);
			ENTITY.SET_ENTITY_MAX_SPEED(playerPed, 100);
			ENTITY.SET_ENTITY_MAX_SPEED(player, 100);
			-- show game title screen when game mode not set
			if(BB.data["game_mode"] == 0) then
				BB.data["game_scanner"]=false;
				BB.drawText("Blue Balls",  0.1, 0.49, 3.0, true, 1, 63, 127, 255);
				BB.drawText("v:"..BB.data["version"], 0.21, 0.68, 0.3, false, 1, 255, 255, 255);
				BB.drawText("by CoreLogic 2015", 0.24, 0.35, 0.5, false, 1, 255, 255, 255);
				--DS.drawText("[h]elp", 0.24, 0.63, 0.5, false, 1, 255, 255, 255);
				BB.drawText("Game Mode:", 0.34, 0.49, 1.0, true, 1, 255, 255, 255);
				BB.drawText("[1] Go!", 0.44, 0.49, 1.0, true, 1, 255, 255, 0);
				BB.drawText("[2] Timed", 0.53, 0.48, 1.0, true, 1, 255, 255, 0);
				--BB.drawText("[3] HardCore 3 Lives.", 0.60, 0.49, 1.0, true, 1, 255, 0, 0);
			elseif(BB.data["game_mode"] == 1) then
				BB.data["game_scanner"]=true;
		    elseif(BB.data["game_mode"] == 2) then
				BB.data["game_scanner"]=true;	
		    end
			-- main control point, scan for new peds and run game logic?	
			if(BB.data["game_scanner"])then
				-- capture when player touches his blue balls
				BB.checkYoga();
				-- tell the player what to do when they start the game
				if(BB.toggle["spawn_dialog"]) then
					if (BB.timer["spawn_timer"] > 0)  then
						BB.drawText("Blue Balls",  0.1, 0.52, 3.0, true, 1, 63, 127, 255);
						BB.drawText("Catch Blue Balls to score!", 0.24, 0.52, 1.10, true, 0, 255, 0, 0);
						BB.drawText("Head shots will send balls to you,\nwounded peds yeld more balls!", 0.36, 0.52, 0.66, true, 0, 0, 0, 0);
						BB.drawText("Cars, bullets, walls will pop balls!\nSome are trolls you can't pick up!", 0.49, 0.51, 0.6, true, 0, 0, 0, 0);
						BB.timer["spawn_timer"] = BB.timer["spawn_timer"] - 1;
					else
						BB.timer["spawn_timer"] = 0;
						BB.toggle["spawn_dialog"] = false;
					end
				end
				-- avoid crashing machine, delete objects when they exceed max set by player	
				if(#BB.data["objects"] > BB.settings["max_objects"])then
					BB.cleanAll();
				end
				-- should we run the game logic?	
				if(BB.toggle["game_scanner"]) then
					BB.newPedScanner();
					BB.updatecheck();
				end -- end scanner
				
				local num_balls = #BB.data["touched"];
				BB.drawText("Balls:"..num_balls, 0.01, 0.01, 0.76, false, 0, 63, 127, 255);
				local scr = num_balls * 6;
				BB.drawText("Score:"..scr, 0.01, 0.76, 0.80, false, 0, 63, 127, 255);
				-- # of seen peds
				local num_peds = #BB.data["seenPeds"];
				BB.drawText("T:"..num_peds, 0.94, 0.39, 0.26, true, 0, 255, 255, 0);
				-- dead peds
				local num_dead = #BB.data["deadPeds"];
				BB.drawText("K:"..num_dead, 0.94, 0.47, 0.26, true, 0, 255, 255, 0);
				-- number of objects spawned by dead peds
				local num_objects = #BB.data["objects"];
				BB.drawText("O:"..num_objects, 0.94, 0.56, 0.26, true, 0, 255, 255, 0);
				-- game mode 1 end key CTA
				if(BB.data["game_mode"] == 1) then
					BB.drawText("[Space] to end..", 0.76, 0.059, 0.30, true, 0, 0, 255, 0);
				end
				-- Game timer (game mode 2)
				if(BB.data["game_mode"] == 2) then
					if(BB.timer["game_timer"] > 0) then
						BB.drawText("Time:"..BB.timer["game_timer"], 0.01, 0.46, 0.66, true, 0, 255, 255, 0);
						BB.timer["game_timer"] = BB.timer["game_timer"] - 1;
					else
						BB.drawText("Time:"..BB.timer["game_timer"], 0.01, 0.46, 0.66, true, 0, 255, 0, 0);
						BB.timer["game_timer"] = 0;
						BB.gameOver();
					end
				end
				-- Register a touch hit msg on screen
				if(BB.toggle["touched"]) then
					if(BB.timer["touched"] > 0)then
						print("touched..");
						BB.drawText(BB.settings["touch_msg"], 0.44, 0.46, 1.96, true, 0, 0, 255, 0);
						BB.timer["touched"] = BB.timer["touched"] - 1;
					else
						BB.toggle["touched"]=false;
						BB.timer["touched"]=BB.settings["hit_msg_delay"];
					end
				end
			end -- scanner	
		end	-- player exists and not dead
	end -- playgame
end -- tick
function BB.gameOver()
	print("Game over!");
	BB.data["playGame"] = false;
	BB.toggle["game_scanner"] = false;
	BB.data["game_over"] = true;
end
function BB.cleanAll()
	for i=1, #BB.data["objects"] do
	    local b = BB.data["objects"][i];
		if (b ~= nil) then
			OBJECT.DELETE_OBJECT(BB.data["objects"][i]);
			BB.data["objects"][i] = nil;
		end
	end
	BB.data["objects"] = {};
end
function BB.unload()
	BB.cleanAll();
	print("Flip All The Things. - by CoreLogic");
end
function BB.onload()
	print("I live...");
end
	
return BB;