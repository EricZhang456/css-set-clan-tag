#include <sourcemod>
#include <clientprefs>
#include <cstrike>

#define BASE_STR_LEN 128

public Plugin myinfo = {
    name = "CS Set Clan Tag",
    author = "Eric Zhang",
    description = "Set client clan tag in CS.",
    version = "1.0",
    url = "https://ericaftereic.top"
};

Cookie g_cClanTag;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    char game[BASE_STR_LEN];
    GetGameFolderName(game, sizeof(game));
    if (StrEqual(game, "cstrike") || StrEqual(game, "csgo")) {
        return APLRes_Success;
    }
    strcopy(error, err_max, "This plugin only works in CS:S and CS:GO");
    return APLRes_SilentFailure;
}

public void OnPluginStart() {
    LoadTranslations("cs-set-clan-tag.phrases");
    g_cClanTag = new Cookie("cs_custom_clantag", "Custom clan tag", CookieAccess_Protected);
    RegConsoleCmd("sm_setclantag", Cmd_SetClanTag, "Set custom clan tag");
    RegConsoleCmd("sm_unsetclantag", Cmd_UnsetClanTag, "Unset custom clan tag");
    HookEvent("player_team", Event_PlayerTeam);
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!AreClientCookiesCached(client)) {
        return;
    }
    char clanTag[BASE_STR_LEN];
    g_cClanTag.Get(client, clanTag, sizeof(clanTag));
    if (!strlen(clanTag)) {
        CS_SetClientClanTag(client, clanTag);
    }
}

public Action Cmd_SetClanTag(int client, int args) {
    if (client <= 0) {
        return Plugin_Continue;
    }
    char clanTag[BASE_STR_LEN];
    GetCmdArgString(clanTag, sizeof(clanTag));
    if (StrEqual(clanTag, "")) {
        ReplyToCommand(client, "%t", "CS_SET_CLAN_TAG_EMPTY");
        return Plugin_Handled;
    }
    g_cClanTag.Set(client, clanTag);
    CS_SetClientClanTag(client, clanTag);
    ReplyToCommand(client, "%t", "CS_SET_CLAN_TAG_SET", clanTag);
    return Plugin_Handled;
}

public Action Cmd_UnsetClanTag(int client, int args) {
    if (client <= 0) {
        return Plugin_Continue;
    }
    g_cClanTag.Set(client, "");
    ReplyToCommand(client, "%t", "CS_SET_CLAN_TAG_UNSET");
    return Plugin_Handled;
}
