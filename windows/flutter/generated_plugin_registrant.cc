//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <win_toast/win_toast_plugin.h>
#include <windows_notification/windows_notification_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  WinToastPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WinToastPlugin"));
  WindowsNotificationPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsNotificationPluginCApi"));
}
