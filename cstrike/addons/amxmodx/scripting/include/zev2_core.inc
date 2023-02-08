#if AMXX_VERSION_NUM >= 175
    #pragma reqlib zev2_core
    #if !defined AMXMODX_NOAUTOLOAD
        #pragma loadlib zev2_core
    #endif
#else
    #pragma library zev2_core
#endif

native ZEV2_GetOriginZombie();
native ZEV2_SetOriginZombie(index);
native ZEV2_InfectPlayer(index);
native ZEV2_HealPlayer(index);
native ZEV2_IsUserZombie(index);