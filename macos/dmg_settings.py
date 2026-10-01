app = "Shuru-Up Business"
dmg_settings = {
    'title': f'{app}',
    'icon': 'macos/Runner/Assets.xcassets/AppIcon.appiconset/1024.png',  # Ensure the path is correct
    'applications_link': True,
#     'background': 'macos/background.png',  # Optional, set this if you have a custom background
    'window_rect': ((100, 100), (600, 400)),
    'icon_positions': {
        f'{app}.app': (140, 120),
        'Applications': (500, 120),
    },
        'files': [
            # Add the path to your built `.app` file here
            ('build/macos/Build/Products/Release/MyApp.app', f'{app}.app'),
        ]

}
