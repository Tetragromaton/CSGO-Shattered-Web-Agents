#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Tetragromaton"
#define PLUGIN_VERSION "1.4"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <smlib>
//#pragma newdecls required
#include <clientprefs>
EngineVersion g_Game;
char MDL[][] ={
	"tm_balkan_variantf",	// 13	0 1		"Dragomir | Sabre"					"Драгомир | Кавалерия"
	"tm_balkan_variantg",	// 18	0 2		"Rezan The Ready | Sabre"			"Резан Готовый | Кавалерия"
	"tm_balkan_varianth",	// 21	0 3		"'The Doctor' Romanov | Sabre"		"«Доктор» Романов | Кавалерия"
	"tm_balkan_varianti",	// 9	0 4		"Maximus | Sabre"					"Максимус | Кавалерия"
	"tm_balkan_variantj",	// 14	0 5		"Blackwolf | Sabre"					"Черноволк | Кавалерия"
	"tm_leet_variantf",		// 22	0 6		"The Elite Mr. Muhlik | Elite Crew"	"Элитный мистер Мохлик | Элитный отряд"
	"tm_leet_variantg",		// 4	0 7		"Ground Rebel  | Elite Crew"		"Диверсант  | Элитный отряд"
	"tm_leet_varianth",		// 11	0 8		"Osiris | Elite Crew"				"Осирис | Элитный отряд"
	"tm_leet_varianti",		// 17	0 9		"Prof. Shahmat | Elite Crew"		"Профессор Шахмат | Элитный отряд"
	"tm_phoenix_variantf",	// 5	0 10	"Enforcer | Phoenix"				"Головорез | Феникс"
	"tm_phoenix_variantg",	// 12	0 11	"Slingshot | Phoenix"				"Мясник | Феникс"
	"tm_phoenix_varianth",	// 6	0 12	"Soldier | Phoenix"					"Солдат | Феникс"

	"ctm_fbi_variantb",		// 20	1 1		"Special Agent Ava | FBI"			"Особый агент Ава | ФБР"
	"ctm_fbi_variantf",		// 3	1 2		"Operator | FBI SWAT"				"Оперативник | ФБР: SWAT"
	"ctm_fbi_variantg",		// 8	1 3		"Markus Delrow | FBI HRT"			"Маркус Делроу | ФБР: антитеррор"
	"ctm_fbi_varianth",		// 15	1 4		"Michael Syfers  | FBI Sniper"		"Майкл Сайферс  | ФБР: снайпер"
	"ctm_sas_variantf",		// 7	1 5		"B Squadron Officer | SAS"			"Офицер отряда B | SAS"
	"ctm_st6_variante",		// 1	1 6		"Seal Team 6 Soldier | NSWC SEAL"	"Солдат SEAL Team 6 | NSWC SEAL"
	"ctm_st6_variantg",		// 10	1 7		"Buckshot | NSWC SEAL"				"Бакшот | NSWC SEAL"
	"ctm_st6_varianti",		// 19	1 8		"Lt. Commander Ricksaw | NSWC SEAL"	"Капитан 3-го ранга Риксоу | NSWC SEAL"
	"ctm_st6_variantk",		// 2	1 9		"3rd Commando Company | KSK"		"Третья рота коммандо | KSK"
	"ctm_st6_variantm"		// 16	1 10	"'Two Times' McCoy | USAF TACP"		"«Дважды» МакКой | USAF TACP"	
};
//^Thanks to Grey83 from hlmod
//Also thanks to Феникс, for understating how 2 read/write data from tables with offs. <3

public Plugin myinfo = 
{
	name = "Special Skins(Agents)",
	author = PLUGIN_AUTHOR,
	description = "Аегнты из обновления Расколотая сеть/Agents from Shattered Web",
	version = PLUGIN_VERSION,
	url = "github.com/Tetragromaton"
};



Handle g_sDataSkin;//Terrorist
Handle g_sDataSKIN_CT;//CT

Handle g_iAgentPatchSLOT1;
Handle g_iAgentPatchSLOT2;
Handle g_iAgentPatchSLOT3;
Handle g_iAgentPatchSLOT4;
Handle g_iAgentPatchSLOT5;

int LocalPatch[MAXPLAYERS + 1] = -1;

ConVar g_fApplyTimeCVS;
int g_iAgentSoundpack[MAXPLAYERS +1] = -1;
public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	RegConsoleCmd("ssf", SpecialSkin3);
	RegConsoleCmd("agents", SpecialSkin3);
	HookEvent("player_spawn", OnPlayerSpawn);
	g_sDataSkin = RegClientCookie("ss_skin_t", "", CookieAccess_Private);
	g_sDataSKIN_CT = RegClientCookie("ss_skin_ct", "", CookieAccess_Private);
	g_iAgentPatchSLOT1 = RegClientCookie("ss_patch_slot1", "", CookieAccess_Private);
	g_iAgentPatchSLOT2 = RegClientCookie("ss_patch_slot2", "", CookieAccess_Private);
	g_iAgentPatchSLOT3 = RegClientCookie("ss_patch_slot3", "", CookieAccess_Private);
	g_iAgentPatchSLOT4 = RegClientCookie("ss_patch_slot4", "", CookieAccess_Private);
	g_iAgentPatchSLOT5 = RegClientCookie("ss_patch_slot5", "", CookieAccess_Private);
	
	g_fApplyTimeCVS = CreateConVar("agents_applytime", "1.3", "Time needed to skin to be applied on player");
	LoadTranslations("agents_selector.phrases");
	AutoExecConfig(true, "AgentsSelector");
	AddNormalSoundHook(VoiceLineSounds);
}
int GetPatchInSlot(client, int slot = -1)
{
	int valx = 0;
	switch(slot)
	{
		case 0:
		{
			char Temp[36];
			GetClientCookie(client, g_iAgentPatchSLOT1, Temp, sizeof(Temp));
			valx = StringToInt(Temp);
		}
		case 1:
		{
			char Temp[36];
			GetClientCookie(client, g_iAgentPatchSLOT2, Temp, sizeof(Temp));
			valx = StringToInt(Temp);
		}
		case 2:
		{
			char Temp[36];
			GetClientCookie(client, g_iAgentPatchSLOT3, Temp, sizeof(Temp));
			valx = StringToInt(Temp);
		}	
		case 3:
		{
			char Temp[36];
			GetClientCookie(client, g_iAgentPatchSLOT4, Temp, sizeof(Temp));
			valx = StringToInt(Temp);
		}	
		case 4:
		{
			char Temp[36];
			GetClientCookie(client, g_iAgentPatchSLOT5, Temp, sizeof(Temp));
			valx = StringToInt(Temp);
		}		
		default:
		{
		}
	}
	return valx;
}
SetPatchInSlot(client, int slot = -1, int value)
{
	char Convert[36];
	IntToString(value, Convert, sizeof(Convert));
	switch(slot)
	{
		case 0:
		{
			SetClientCookie(client, g_iAgentPatchSLOT1, Convert);
		}
		case 1:
		{
			SetClientCookie(client, g_iAgentPatchSLOT2, Convert);
		}
		case 2:
		{
			SetClientCookie(client, g_iAgentPatchSLOT3, Convert);
		}	
		case 3:
		{
			SetClientCookie(client, g_iAgentPatchSLOT4, Convert);
		}	
		case 4:
		{
			SetClientCookie(client, g_iAgentPatchSLOT5, Convert);
		}		
		default:
		{
			
		}
	}
}
public Action SpecialSkin_Patches(iClient,args)
{

}

PostEditSoundPath(String:input[], String:output[], int size)
{
	//Many of voice lines are different at the end of the path, sooooooo we have to change them to valid ones.
	ReplaceString(input, 255, "radiobotreponse", "");
	ReplaceString(input, 255, "radiobot", "");
	ReplaceString(input, 255, "positive", "affirmation_");
	ReplaceString(input, 255, "cheer", "cheer_");
	ReplaceString(input, 255, "hold", "request_hold_");
	ReplaceString(input, 255, "affirmative", "affirmation_");
	ReplaceString(input, 255, "agree", "agree_");
	ReplaceString(input, 255, "negative", "negative_");
	ReplaceString(input, 255, "negativeno", "negative_");
	ReplaceString(input, 255, "onarollbrag", "compliment_");
	ReplaceString(input, 255, "preventescapebrag", "compliment_");
	ReplaceString(input, 255, "radiobothold", "request_hold_");
	ReplaceString(input, 255, "radio_followme", "request_follow_me_");
	ReplaceString(input, 255, "radio_locknload", "request_follow_me_");
	ReplaceString(input, 255, "thanks", "thankful_");
	ReplaceString(input, 255, "radio_enemyspotted", "sees_enemy_");
	ReplaceString(input, 255, "radio_needbackup", "request_backup_");
	ReplaceString(input, 255, "followingfriend", "following_friend_");
	ReplaceString(input, 255, "clearedarea", "sees_area_clear_");
	ReplaceString(input, 255, "inposition", "at_position_");
	ReplaceString(input, 255, "spottedloosebomb", "sees_dropped_bomb_");
	ReplaceString(input, 255, "radiobotreponsepositive", "affirmation_");
	ReplaceString(input,255, "followme", "request_follow_me_");
	ReplaceString(input,255, "target", "sees_enemy_");
	ReplaceString(input,255, "underfire", "takingfire_");
	ReplaceString(input,255, "followyou", "following_friend_");
	ReplaceString(input, 255, "clear", "sees_area_clear_");
	ReplaceString(input, 255, "at_position", "omw_position");
	return Format(output, size, "%s", input);
}
public Action:VoiceLineSounds(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &client, &channel, &Float:volume, &level, &pitch, &flags){
	//**Reserved, replacing path are bad idea, but can work.
		//	PrintToChatAll("%s", sample);
if(IsValidClient(client))
{
if(IsPlayerAlive(client))
	{
		//PrintToChat(client, "%i %s %i", g_iAgentSoundpack[client], sample, channel);		
		if(g_iAgentSoundpack[client] > 0)
		{
		if(StrContains(sample, "player\\vo\\", false) != -1)
		{
			//Extreme shit code below.
			//ReplaceString(sample, sizeof(sample), "player", "+player");		
			//sBuffer - input string ?
			//Sparts how many substrings will be[3] means 3 will be inside array, iParts how many got.
			//sParts [255] - How many item strings(more than 255 result fail) [255] - size of this string
			//Working with explode strings for the first time, so dont judge 
			int iParts;
			char sParts[36][255];
			if((iParts = ExplodeString(sample, "\\", sParts, sizeof(sParts), sizeof(sParts[]))) <= 7)
			{
				int i = 0;
				//PrintToChatAll("INCOMING VALUE SPLITS %i", iParts);
				for(i = 0; i < iParts; ++i)
				{
					//FormatEx(sBuffer, sizeof(sBuffer), "%s->%s", g_sFeature, g_sGrens[i][7]);
					//PrintToChatAll("DEBUG RES: SUBSTR:%i STRING:%s", i, sParts[i]);
					if(i == 3)//Voice name path goes here.
					{
						//PrintToChatAll("DEBUG STOP HERE IE ID %i", i);
						//PrintToChatAll("DEBUG RES: SUBSTR:%i STRING:%s", i, sParts[i]);
						char Output[64];
						char Tempp[64];
						strcopy(Tempp, sizeof(Tempp), sParts[i]);
						strcopy(Output, sizeof(Output), sParts[i]);
						PostEditSoundPath(Output, Output, 64);
						ReplaceString(sample, sizeof(sample), Tempp, Output);
						//PrintToChatAll("Baked %s", Output);
						break;
					}
				}
			}
			//PrintToChatAll("%s", sample);
			switch(g_iAgentSoundpack[client])
			{
				case 4:
				{
					ReplaceString(sample, sizeof(sample), "anarchist", "leet_epic");
					ReplaceString(sample, sizeof(sample), "balkan", "leet_epic");
					ReplaceString(sample, sizeof(sample), "leet", "leet_epic");
					ReplaceString(sample, sizeof(sample), "phoenix", "leet_epic");
					ReplaceString(sample, sizeof(sample), "separatist", "leet_epic");	
					char gg[255];
					PostEditSoundPath(sample, gg, 255);
					char Temp[255];
					strcopy(Temp, sizeof(Temp), gg);
					//ReplaceString(Temp, sizeof(Temp), "+player", "player");
					PrecacheSound(Temp);
					EmitSoundToAll(Temp, client, channel, level, flags, volume);
					return Plugin_Changed;
				}					
				case 3:
				{
					ReplaceString(sample, sizeof(sample), "anarchist", "balkan_epic");
					ReplaceString(sample, sizeof(sample), "balkan", "balkan_epic");
					ReplaceString(sample, sizeof(sample), "leet", "balkan_epic");
					ReplaceString(sample, sizeof(sample), "phoenix", "balkan_epic");
					ReplaceString(sample, sizeof(sample), "separatist", "balkan_epic");
					char gg[255];
					PostEditSoundPath(sample, gg, 255);
					ReplaceString(sample, sizeof(sample), gg, "");
					//PrintToChat(client, "GS%s", gg);
					char Temp[255];
					strcopy(Temp, sizeof(Temp), gg);
					ReplaceString(Temp, sizeof(Temp), "__", "_");
					ReplaceString(Temp, sizeof(Temp), "request_request_", "request_");
					ReplaceString(Temp, sizeof(Temp), "+player", "player");
					PrecacheSound(Temp);
					EmitSoundToAll(Temp, client, channel, level, flags, volume);
					return Plugin_Handled;
				}				
				case 2:
				{
					ReplaceString(sample, sizeof(sample), "fbihrt", "seal_epic");
					ReplaceString(sample, sizeof(sample), "gign", "seal_epic");
					ReplaceString(sample, sizeof(sample), "idf", "seal_epic");
					ReplaceString(sample, sizeof(sample), "sas", "seal_epic");
					ReplaceString(sample, sizeof(sample), "swat", "seal_epic");
					ReplaceString(sample, sizeof(sample), "seal", "seal_epic");
					char gg[255];
					PostEditSoundPath(sample, gg, 255);
					char Temp[255];
					strcopy(Temp, sizeof(Temp), gg);
					ReplaceString(Temp, sizeof(Temp), "__", "_");
					ReplaceString(Temp, sizeof(Temp), "request_request_", "request_");
					ReplaceString(Temp, sizeof(Temp), "sees_area_sees_area_clear_", "sees_area_clear_");					
					PrecacheSound(Temp);
					EmitSoundToAll(Temp, client, channel, level, flags, volume);
					return Plugin_Changed;
				}				
				case 1:
				{
					ReplaceString(sample, sizeof(sample), "fbihrt", "fbihrt_epic");
					ReplaceString(sample, sizeof(sample), "gign", "fbihrt_epic");
					ReplaceString(sample, sizeof(sample), "idf", "fbihrt_epic");
					ReplaceString(sample, sizeof(sample), "sas", "fbihrt_epic");
					ReplaceString(sample, sizeof(sample), "swat", "fbihrt_epic");
					ReplaceString(sample, sizeof(sample), "seal", "fbihrt_epic");
					char gg[255];
					PostEditSoundPath(sample, gg, 255);
					char Temp[255];
					strcopy(Temp, sizeof(Temp), gg);
					ReplaceString(Temp, sizeof(Temp), "__", "_");
					ReplaceString(Temp, sizeof(Temp), "request_request_", "request_");
					ReplaceString(Temp, sizeof(Temp), "sees_area_sees_area_clear_", "sees_area_clear_");
					PrecacheSound(Temp);
					//PrintToChatAll(Temp);
					EmitSoundToAll(Temp, client, channel, level, flags, volume);
					return Plugin_Changed;
				}
				default:
				{
					return Plugin_Continue;
				}
			}
		}
		}
	}
}
return Plugin_Continue;
} 
public IsValidClient(client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
		return false;
	
	return true;
}
public Action OnPlayerSpawn(Event eEvent, const char[] sName, bool bDontBroadcast)
{
	new client = GetClientOfUserId(eEvent.GetInt("userid"));
	if (client)
	{
		if(IsValidClient(client))
		{
			g_iAgentSoundpack[client] = -1;
			float time = GetConVarFloat(g_fApplyTimeCVS);
			CreateTimer(time, ApplySkin, client);
		}
	}
}
public OnClientPutInServer(client)
{
	g_iAgentSoundpack[client] = -1;
}
public OnClientDisconnect(client)
{
	g_iAgentSoundpack[client] = -1;
}
public Action ApplySkin(Handle timer, any:client)
{
	if (!IsValidClient(client))return;
	char SkinNISMO[255];
	GetClientCookie(client, g_sDataSkin, SkinNISMO, sizeof(SkinNISMO));
	char SkinNISMOXTUNE[255];
	GetClientCookie(client, g_sDataSKIN_CT, SkinNISMOXTUNE, sizeof(SkinNISMOXTUNE));
	bool AreAgent = false;
	if(!StrEqual(SkinNISMO, "") && GetClientTeam(client) == CS_TEAM_CT)
	{
		if (!IsModelPrecached(SkinNISMO))PrecacheModel(SkinNISMO);
		Entity_SetModel(client, SkinNISMO);
		g_iAgentSoundpack[client] = GetVoiceLineID(SkinNISMO);
		AreAgent = true;
	}else if (!StrEqual(SkinNISMOXTUNE, "") && GetClientTeam(client) == CS_TEAM_T)
	{
		if (!IsModelPrecached(SkinNISMOXTUNE))PrecacheModel(SkinNISMOXTUNE);
		Entity_SetModel(client, SkinNISMOXTUNE);	
		//PrintToChatAll("DEBUG 3");
		g_iAgentSoundpack[client] = GetVoiceLineID(SkinNISMOXTUNE);
		AreAgent = true;
	}
	if(AreAgent){
	int iSize = GetEntPropArraySize(client, Prop_Send, "m_vecPlayerPatchEconIndices");
	for(int i = 0; i < iSize; i++)
	{
	int PatchID = GetPatchInSlot(client, i);
	SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", PatchID, 4, i);
	}
	}	
}
int GetVoiceLineID(const char[] modelname)
{
	char Wrapper[1024];
	int SIDPACK = -1;
	for (new i = 0; i < sizeof(MDL); i ++)
	{
		if(!StrEqual(MDL[i], ""))
		{
		Format(Wrapper, sizeof(Wrapper), "models/player/custom_player/legacy/%s.mdl", MDL[i]);
		if(StrEqual(modelname, Wrapper))
		{
			//PrintToChatAll("ловушка джокера");
			SIDPACK = i;
			break;
		}
		}
	}
	//PrintToChatAll("DEBUG ID %i", SIDPACK);
	switch(SIDPACK)
	{
		case 5:
		{
			SIDPACK = 4;
		}
		case 2:
		{
			SIDPACK = 3;//KFC DIRECTOR
		}
		case 19:
		{
			SIDPACK = 2;//soldier guy
		}
		case 12:
		{
			SIDPACK = 1;//Fbi AVATARKA LOOLOL(avtory 0 let)
		}
		//Not all models has it's own unique voice line so i want to specify it. And yea ! Finally I've started to comment what i do lol. I did it before but oof.
		//Lol here is only 4 agents with their new voice line, oof.
		default:
		{
			SIDPACK = -1;
		}
	}
	return SIDPACK;
}
public Action SpecialSkin3(client,args)
{
	new Handle:menu = CreateMenu(AgencySELECTOR, MenuAction_Select  | MenuAction_End);
	char Wrapper[255];
	SetMenuTitle(menu, "%t", "MenuTitle_AgentType");
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_AgentReset");
	AddMenuItem(menu, "Reset", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_PickPatch_TITLE");
	AddMenuItem(menu, "Patch", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_AgentDist");
	AddMenuItem(menu, "DeservedAGENCY", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_AgentExceptional");
	AddMenuItem(menu, "NomineeSDX", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_AgentSuperior");
	AddMenuItem(menu, "PerfectAGNT", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_Master");
	AddMenuItem(menu, "MasterAGENT", Wrapper);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);	
}
public AgencySELECTOR(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			new String:item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			if (StrEqual(item, "DeservedAGENCY"))
			{
				SelectorMENUGEN(param1, 1);
			}
			else if (StrEqual(item, "NomineeSDX"))
			{
				SelectorMENUGEN(param1, 2);
			}
			else if (StrEqual(item, "PerfectAGNT"))
			{
				SelectorMENUGEN(param1, 3);
			}
			else if (StrEqual(item, "MasterAGENT"))
			{
				SelectorMENUGEN(param1, 4);
			}else if(StrEqual(item, "Reset"))
			{
				SetClientCookie(param1, g_sDataSkin, "");
				SetClientCookie(param1, g_sDataSKIN_CT, "");
				PrintToChat(param1, "%t", "Agents_Reseted");
			}else if(StrEqual(item, "Patch"))
			{
				ShowSelectionPatches(param1);
			}
		}

		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}
ShowSelectionPatches(client)
{
	new Handle:menu = CreateMenu(MAINER_PATCH, MenuAction_Select | MenuAction_End | MenuAction_DisplayItem);
	SetMenuTitle(menu, " \n ");
	char Wrapper[1024];
	Format(Wrapper, sizeof(Wrapper), "%t\n ", "MenuTitle_PickPatch_Reset");
	AddMenuItem(menu, "RESET", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_PAYBACK");
	AddMenuItem(menu, "4567", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_BRAVO");
	AddMenuItem(menu, "4563", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_PHOENIX");
	AddMenuItem(menu, "4568", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_BREAKOUT");
	AddMenuItem(menu, "4564", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_VANGUARD");
	AddMenuItem(menu, "4570", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_BLOODHOUND");
	AddMenuItem(menu, "4562", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_WILDFIRE");
	AddMenuItem(menu, "4560", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_HYDRA");
	AddMenuItem(menu, "4566", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_SHATTERED");
	AddMenuItem(menu, "4569", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_DANGERZONE");
	AddMenuItem(menu, "4565", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_EZPZ");
	AddMenuItem(menu, "4555", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_CHICKENLOVER");
	AddMenuItem(menu, "4552", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_CRAZYBANANA");
	AddMenuItem(menu, "4550", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_CLUTCH");
	AddMenuItem(menu, "4553", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_KOI");
	AddMenuItem(menu, "4558", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_LONGEVITY");
	AddMenuItem(menu, "4559", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_VIGILANCE");
	AddMenuItem(menu, "4561", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_RAGE");
	AddMenuItem(menu, "4556", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_DRAGON");
	AddMenuItem(menu, "4554", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_BOSS");
	AddMenuItem(menu, "4551", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "ITEM_HOWL");
	AddMenuItem(menu, "4557", Wrapper);	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
public MAINER_PATCH(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			new String:item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "RESET"))
			{
				SetPatchInSlot(param1, 1, 0);
				SetPatchInSlot(param1, 2, 0);
				SetPatchInSlot(param1, 3, 0);
				SetPatchInSlot(param1, 4, 0);
				SetPatchInSlot(param1, 5, 0);
				PrintToChat(param1, "%t", "MenuTitle_PatchAllReset");
				return;
			}
			int PatchID = StringToInt(item);
			LocalPatch[param1] = PatchID;
			ProcessSelection(param1);
		}
		case MenuAction_Cancel:
 		{
 			SpecialSkin3(param1, 0);
 		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}
ProcessSelection(client)
{
	new Handle:menu = CreateMenu(MAINER_PATCH_SLOT, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, " \n");//2 lazy 2 define.
	char Wrapper[1024];
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_PickForSlot", "1");
	AddMenuItem(menu, "0", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_PickForSlot", "2");
	AddMenuItem(menu, "1", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_PickForSlot", "3");
	AddMenuItem(menu, "2", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_PickForSlot", "4");
	AddMenuItem(menu, "3", Wrapper);	
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_PickForSlot", "5");
	AddMenuItem(menu, "4", Wrapper);
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_PickForAllSlots");
	AddMenuItem(menu, "ALL", Wrapper);	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
public MAINER_PATCH_SLOT(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			new String:item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			int Slot = StringToInt(item);
			if(StrEqual(item, "ALL"))
			{
				SetPatchInSlot(param1, 0, LocalPatch[param1]);
				SetPatchInSlot(param1, 1, LocalPatch[param1]);
				SetPatchInSlot(param1, 2, LocalPatch[param1]);
				SetPatchInSlot(param1, 3, LocalPatch[param1]);
				SetPatchInSlot(param1, 4, LocalPatch[param1]);
				PrintToChat(param1, "%t", "MenuTitle_PatchInstalled");
				return;
			}
			PrintToChat(param1, "%t", "MenuTitle_PatchInstalled");
			SetPatchInSlot(param1, Slot, LocalPatch[param1]);
		}
 		case MenuAction_Cancel:
 		{
 			SpecialSkin3(param1, 0);
 			//ShowSelectionPatches(param1);
 		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}
SelectorMENUGEN(client, int type)
{
	new Handle:menu = CreateMenu(XCGSelector, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
	SetMenuTitle(menu, "%t", "MenuTitle_PickIt");
	char Wrapper[1024];
	switch(type)
	{
		case 4://Мастерские
		{
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_19");
			AddMenuItem(menu, "19", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_20");
			AddMenuItem(menu, "20", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_21");
			AddMenuItem(menu, "21", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_22");
			AddMenuItem(menu, "22", Wrapper);
		}
		case 3://Превосходные агенты
		{
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_14");
			AddMenuItem(menu, "14", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_15");
			AddMenuItem(menu, "15", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_16");
			AddMenuItem(menu, "16", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_17");
			AddMenuItem(menu, "17", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_18");
			AddMenuItem(menu, "18", Wrapper);
		}
		case 2://Исключительные агенты
		{
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_8");
			AddMenuItem(menu, "8", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_9");
			AddMenuItem(menu, "9", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_10");
			AddMenuItem(menu, "10", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_11");
			AddMenuItem(menu, "11", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_12");
			AddMenuItem(menu, "12", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_13");
			AddMenuItem(menu, "13", Wrapper);
		}
		case 1://Заслуженные агенты
		{
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_1");
			AddMenuItem(menu, "1", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_2");
			AddMenuItem(menu, "2", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_3");
			AddMenuItem(menu, "3", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_4");
			AddMenuItem(menu, "4", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_5");
			AddMenuItem(menu, "5", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_6");
			AddMenuItem(menu, "6", Wrapper);
			Format(Wrapper, sizeof(Wrapper), "%t", "AgentSID_7");
			AddMenuItem(menu, "7", Wrapper);
		}
		default:
		{
			//PrintToChat(client, "Not found.");
			CloseHandle(menu);
		}
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
public XCGSelector(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			new String:item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			int SPICK = StringToInt(item);
			char ModelName[255];
			if(SPICK > 0)
			{
				int team = 0;
				switch(SPICK)
				{
					case 6:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_phoenix_varianth.mdl";
					}
					case 12:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_phoenix_variantg.mdl";
					}
					case 5:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_phoenix_variantf.mdl";
					}
					case 17:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_leet_varianti.mdl";
					}
					case 4:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_leet_variantg.mdl";
					}
					case 11:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_leet_varianth.mdl";
					}
					case 14:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_balkan_variantj.mdl";
					}
					case 9:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_balkan_varianti.mdl";
					}
					case 21:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_balkan_varianth.mdl";
					}					
					case 18:
					{
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_balkan_variantg.mdl";
					}
					case 13:
					{ 
						team = 2;
						ModelName = "models/player/custom_player/legacy/tm_balkan_variantf.mdl";
					}
					case 16:
					{
						team = 1;
						ModelName = "models/player/custom_player/legacy/ctm_st6_variantm.mdl";
					}
					case 19:
					{
						team = 1;
						ModelName = "models/player/custom_player/legacy/ctm_st6_varianti.mdl";
					}
					case 10:
					{
						team = 1;
						ModelName = "models/player/custom_player/legacy/ctm_st6_variantg.mdl";
					}
					case 7:
					{
						team = 1;
						ModelName = "models/player/custom_player/legacy/ctm_sas_variantf.mdl";
					}
					case 15:
					{
						team = 1;
						ModelName = "models/player/custom_player/legacy/ctm_fbi_varianth.mdl";
					}
					case 8:
					{
						team = 1;
						ModelName = "models/player/custom_player/legacy/ctm_fbi_variantg.mdl";
					}
					case 20:
					{
						team = 1;
						ModelName = "models/player/custom_player/legacy/ctm_fbi_variantb.mdl";
					}
					case 22:
					{
						team = 2;//T
						ModelName = "models/player/custom_player/legacy/tm_leet_variantf.mdl";
					}
					case 3:
					{
						team = 1;
						ModelName = "models/player/custom_player/legacy/ctm_fbi_variantf.mdl";
					}
					case 1:
					{
						team = 1;//CT
						ModelName = "models/player/custom_player/legacy/ctm_st6_variante.mdl";
					}
					case 2:
					{
						team = 1;
						ModelName = "models/player/custom_player/legacy/ctm_st6_variantk.mdl";
					}
				}
				//PrintToChatAll("%s", ModelName);
				
				if(team == 1)
				{
					SetClientCookie(param1, g_sDataSkin, ModelName);
					PrintToChat(param1, "%t", "Agent_PickedCT");
				}else if(team == 2)
				{
					PrintToChat(param1, "%t", "Agent_PickedT");
					SetClientCookie(param1, g_sDataSKIN_CT, ModelName);
				}
			}
		}

 		case MenuAction_Cancel:
 		{
 			SpecialSkin3(param1, 0);
 		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}