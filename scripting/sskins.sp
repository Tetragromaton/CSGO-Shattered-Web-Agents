#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Tetragromaton"
#define PLUGIN_VERSION "1.3"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <smlib>
//#pragma newdecls required
#include <clientprefs>
EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "Special Skins(Agents)",
	author = PLUGIN_AUTHOR,
	description = "Аегнты из обновления Расколотая сеть/Agents from Shattered Web",
	version = PLUGIN_VERSION,
	url = "tetradev.org"
};
Handle g_sDataSkin;//Terrorist
Handle g_sDataSKIN_CT;//CTF
ConVar g_fApplyTimeCVS;
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
	g_fApplyTimeCVS = CreateConVar("agents_applytime", "1.3", "Time needed to skin to be applied on player");
	LoadTranslations("agents_selector.phrases");
	AutoExecConfig(true, "AgentsSelector");
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
			float time = GetConVarFloat(g_fApplyTimeCVS);
			CreateTimer(time, ApplySkin, client);
		}
	}
}
public Action ApplySkin(Handle timer, any:client)
{
	if (!IsValidClient(client))return;
	char SkinNISMO[255];
	GetClientCookie(client, g_sDataSkin, SkinNISMO, sizeof(SkinNISMO));
	char SkinNISMOXTUNE[255];
	GetClientCookie(client, g_sDataSKIN_CT, SkinNISMOXTUNE, sizeof(SkinNISMOXTUNE));	
	if(GetClientTeam(client) == CS_TEAM_CT && !StrEqual(SkinNISMO, ""))
	{
		if (!IsModelPrecached(SkinNISMO))PrecacheModel(SkinNISMO);
		Entity_SetModel(client, SkinNISMO);
	}else if (GetClientTeam(client) == CS_TEAM_T && !StrEqual(SkinNISMOXTUNE, ""))
	{
		if (!IsModelPrecached(SkinNISMOXTUNE))PrecacheModel(SkinNISMOXTUNE);
		Entity_SetModel(client, SkinNISMOXTUNE);	
	}
}
public Action SpecialSkin3(client,args)
{
	new Handle:menu = CreateMenu(AgencySELECTOR, MenuAction_Select  | MenuAction_End);
	char Wrapper[255];
	SetMenuTitle(menu, "%t", "MenuTitle_AgentType");
	Format(Wrapper, sizeof(Wrapper), "%t", "MenuTitle_AgentReset");
	AddMenuItem(menu, "Reset", Wrapper);
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
			}
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