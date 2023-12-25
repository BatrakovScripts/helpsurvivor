#include <sourcemod>
#include <sdktools_functions>

//tongue_grab // захват языком
/*
	userid	short	Игрок, который захватил
	victim	short	Игрок, которого захватили
*/

//tongue_broke_victim_died // Язык оборван, жертва умерла.
/*
	userid	short	Игрок, у которого оборвался язык
*/

//lunge_pounce // Напрыгивание (охотник).
/*
	userid	short	Игрок, который напрыгнул
	victim	short	Игрок, на которого напрыгнули
	distance	long	Расстояние с которого напрыгнули
	has_upgrade	bool	Есть ли у игрока освободиться самому
*/
//pounce_stopped // Напрыгивание остановлено (охотник).
/*
	userid	short	Игрок, который остановил
	victim	short	Игрок, на которого прыгали
*/

new bool:incap[MAXPLAYERS];
new smoker[MAXPLAYERS];
new hunter[MAXPLAYERS];
new gethunter;
new getsmoker;

public OnPluginStart()
{
	HookEvent("tongue_grab", ActiveSmoker);
	HookEvent("lunge_pounce", ActiveHunter);
	HookEvent("pounce_stopped", HunterDeath);
	HookEvent("tongue_broke_victim_died", SmokerDeath);
}
public Action:SmokerDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new i  = GetClientOfUserId(GetEventInt(event, "userid"));
	getsmoker = i;
	incap[i] = false;
	hunter[i] = 0;
	smoker[i] = 0;
}
public Action:HunterDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new i  = GetClientOfUserId(GetEventInt(event, "victim"));
	gethunter = i;
	incap[i] = false;
	hunter[i] = 0;
	smoker[i] = 0;
}
//Охотник
public Action:ActiveHunter(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new i  = GetClientOfUserId(GetEventInt(event, "userid"));
	gethunter = i;
	new client  = GetClientOfUserId(GetEventInt(event, "victim"));
	if(IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
	{
		incap[client] = true;
		hunter[client] = 1;
		CreateTimer(1.0, Notification_Two, client);
	}
}
public Action:Notification_Two(Handle:timer, client)
{
	if(client != 0 && IsClientInGame(client) && GetClientTeam(client) == 2  && IsPlayerAlive(client) && !IsFakeClient(client)) 
	{	PrintHintText(client, "Освободите себя от захвата охотника, зажмите *Е*");	}
}

//Курильщик
public Action:ActiveSmoker(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new i  = GetClientOfUserId(GetEventInt(event, "userid"));
	getsmoker = i;
	new client  = GetClientOfUserId(GetEventInt(event, "victim"));
	if(IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
	{
		incap[client] = true;
		smoker[client] = 1;
		CreateTimer(1.0, Notification_One, client);
	}
}
public Action:Notification_One(Handle:timer, client)
{
	if(client != 0 && IsClientInGame(client) && GetClientTeam(client) == 2  && IsPlayerAlive(client) && !IsFakeClient(client)) 
	{	PrintHintText(client, "Освободите себя от языка курильщика, зажмите *Е*"); 	}
}
//
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (buttons & IN_USE && incap[client] == true && client != 0 && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsFakeClient(client))
	{
		for (new i = 1; i <= GetMaxClients(); i++)
		{
			if(smoker[client] == 1)
			{
				incap[client] = false;
				if(IsClientInGame(client) && IsClientInGame(getsmoker)) ForcePlayerSuicide(getsmoker);
				smoker[client] = 0;
			}
			if(hunter[client] == 1)
			{
				incap[client] = false;
				if(IsClientInGame(client) && IsClientInGame(gethunter)) ForcePlayerSuicide(gethunter);
				hunter[client] = 0;
			}
		}
	}
	return Plugin_Continue;
}