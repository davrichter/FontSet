#include "flutter_window.h"
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <iostream>
#include <stdexcept>

#include <optional>

#include "flutter/generated_plugin_registrant.h"

static int InstallFont(LPCSTR fontPath) {
	int returnValue = AddFontResourceA(fontPath);

	return returnValue;
}

const flutter::EncodableValue* ValueOrNull(const flutter::EncodableMap& map, const char* key) {
	auto it = map.find(flutter::EncodableValue(key));
	if (it == map.end()) {
		return nullptr;
	}
	return &(it->second);
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
	: project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
	if (!Win32Window::OnCreate()) {
		return false;
	}

	RECT frame = GetClientArea();

	// The size here must match the window dimensions to avoid unnecessary surface
	// creation / destruction in the startup path.
	flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
		frame.right - frame.left, frame.bottom - frame.top, project_);
	// Ensure that basic setup of the controller was successful.
	if (!flutter_controller_->engine() || !flutter_controller_->view()) {
		return false;
	}

	RegisterPlugins(flutter_controller_->engine());

	flutter::MethodChannel<> channel(
		flutter_controller_->engine()->messenger(), "font_installer.fontset.dev/install_font",
		&flutter::StandardMethodCodec::GetInstance());
	channel.SetMethodCallHandler(
		[](const flutter::MethodCall<>& call,
			std::unique_ptr<flutter::MethodResult<>> result) {
				if (call.method_name() == "installFont") {
					const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
					const auto fontPath = std::get_if<std::string>(ValueOrNull(*arguments, "fontPath"));

					if (fontPath != nullptr) {
						result->Success(InstallFont(fontPath->c_str()));
					}
					else {
						result->Error("ERROR", "Font installation failed. 'fontPath' is nullptr.");
					}
				}
				else {
					result->NotImplemented();
				}
		});

	SetChildContent(flutter_controller_->view()->GetNativeWindow());

	flutter_controller_->engine()->SetNextFrameCallback([&]() {
		this->Show();
		});

	return true;
}

void FlutterWindow::OnDestroy() {
	if (flutter_controller_) {
		flutter_controller_ = nullptr;
	}

	Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
	WPARAM const wparam,
	LPARAM const lparam) noexcept {
	// Give Flutter, including plugins, an opportunity to handle window messages.
	if (flutter_controller_) {
		std::optional<LRESULT> result =
			flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
				lparam);
		if (result) {
			return *result;
		}
	}

	switch (message) {
	case WM_FONTCHANGE:
		flutter_controller_->engine()->ReloadSystemFonts();
		break;
	}

	return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
