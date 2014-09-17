#include "skse/skse_version.h"
#include "skse/PluginAPI.h"
#include <shlobj.h>
#include "Events.h"
#include "Papyrus.h"
#include "Serialization.h"


IDebugLog					g_Log;
const char*					kLogPath = "\\My Games\\Skyrim\\Logs\\EnchantingAwakenedExtender.log";

PluginHandle				g_pluginHandle = kPluginHandle_Invalid;

SKSESerializationInterface*	g_serialization = NULL;
SKSEPapyrusInterface*		g_papyrus = NULL;
SKSEMessagingInterface*		g_messageInterface = NULL;



void InitialLoadSetup()
{
	_MESSAGE("Building Event Sinks...");
	g_equipEventDispatcher->AddEventSink(&g_equipEventHandler);

	//Retrieve the SKSE Mod Event dispatcher
	void * dispatchPtr = g_messageInterface->GetEventDispatcher(SKSEMessagingInterface::kDispatcher_ModEvent);
	g_skseModEventDispatcher = (EventDispatcher<SKSEModCallbackEvent>*)dispatchPtr;

	//Register callbacks and unique ID for serialization
	g_serialization->SetUniqueID(g_pluginHandle, 'EnAw');
	g_serialization->SetRevertCallback(g_pluginHandle, EASerialization::Serialization_Revert);
	g_serialization->SetSaveCallback(g_pluginHandle, EASerialization::Serialization_Save);
	g_serialization->SetLoadCallback(g_pluginHandle, EASerialization::Serialization_Load);
}

void EnchantmentFrameworkMessageReceptor(SKSEMessagingInterface::Message* msg)
{
	if (msg->type == 'Itfc')
	{
		_MESSAGE("Recieved Interface from Enchantment Framework");
		g_enchantmentFramework = reinterpret_cast<EnchantmentFrameworkInterface*>(msg->data);
	}
}

void SKSEMessageReceptor(SKSEMessagingInterface::Message* msg)
{
	static bool active = true;
	if (!active)
		return;

	//Register to recieve interface from Enchantment Framework
	if (msg->type == SKSEMessagingInterface::kMessage_PostLoad)
		active = g_messageInterface->RegisterListener(g_pluginHandle, "egocarib Enchantment Framework", EnchantmentFrameworkMessageReceptor);

	//kMessage_InputLoaded only sent once, on initial Main Menu load
	else if (msg->type == SKSEMessagingInterface::kMessage_InputLoaded)
		InitialLoadSetup();
}


extern "C"
{

bool SKSEPlugin_Query(const SKSEInterface * skse, PluginInfo * info)
{
	g_Log.OpenRelative(CSIDL_MYDOCUMENTS, kLogPath);
	_MESSAGE("Enchanting Awakened Extender\nby egocarib\n\nEA Extender Loading...");

	//Populate info structure
	info->infoVersion	= PluginInfo::kInfoVersion;
	info->name			= "Enchanting Awakened Extender";
	info->version		= 1;

	//Store plugin handle so we can identify ourselves later
	g_pluginHandle = skse->GetPluginHandle();

	//Initial checks
	if (skse->isEditor)
		{ _MESSAGE("Loaded In Editor, Marking As Incompatible"); return false; }
	else if (skse->runtimeVersion != RUNTIME_VERSION_1_9_32_0)
		{ _MESSAGE("Unsupported Runtime Version %08X", skse->runtimeVersion); return false; }

	//Get the serialization interface and query its version
	g_serialization = (SKSESerializationInterface *)skse->QueryInterface(kInterface_Serialization);
	if (!g_serialization)
		{ _MESSAGE("Couldn't Get Serialization Interface"); return false; }
	if (g_serialization->version < SKSESerializationInterface::kVersion)
		{ _MESSAGE("Serialization Interface Too Old (%d Expected %d)", g_serialization->version, SKSESerializationInterface::kVersion); return false; }

	//Get the papyrus interface and query its version
	g_papyrus = (SKSEPapyrusInterface *)skse->QueryInterface(kInterface_Papyrus);
	if (!g_papyrus)
		{ _MESSAGE("Couldn't Get Papyrus nterface"); return false; }
	if (g_papyrus->interfaceVersion < SKSEPapyrusInterface::kInterfaceVersion)
		{ _MESSAGE("Papyrus Interface Too Old (%d Expected %d)", g_papyrus->interfaceVersion, SKSEPapyrusInterface::kInterfaceVersion); return false; }

	//Get the messaging interface and query its version
	g_messageInterface = (SKSEMessagingInterface *)skse->QueryInterface(kInterface_Messaging);
	if(!g_messageInterface)
		{ _MESSAGE("Couldn't Get Messaging Interface"); return false; }
	if(g_messageInterface->interfaceVersion < SKSEMessagingInterface::kInterfaceVersion)
		{ _MESSAGE("Messaging Interface Too Old (%d Expected %d)", g_messageInterface->interfaceVersion, SKSEMessagingInterface::kInterfaceVersion); return false; }

	//Success
	return true;
}

bool SKSEPlugin_Load(const SKSEInterface * skse)
{
	_MESSAGE("Registering Papyrus Interface...");
	g_papyrus->Register(RegisterPapyrusEAExtender);

	//Register callback for SKSE messaging interface
	g_messageInterface->RegisterListener(g_pluginHandle, "SKSE", SKSEMessageReceptor);

	return true;
}

};