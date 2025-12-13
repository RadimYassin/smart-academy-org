import React from 'react';
import { Bell, Shield, Globe, Palette } from 'lucide-react';

const Settings: React.FC = () => {
    const settingsSections = [
        {
            title: 'Notifications',
            icon: Bell,
            items: [
                { label: 'Email Notifications', description: 'Receive email updates about your account', enabled: true },
                { label: 'Push Notifications', description: 'Get push notifications on your devices', enabled: false },
                { label: 'SMS Notifications', description: 'Receive text messages for critical updates', enabled: true },
            ],
        },
        {
            title: 'Privacy & Security',
            icon: Shield,
            items: [
                { label: 'Two-Factor Authentication', description: 'Add an extra layer of security', enabled: true },
                { label: 'Session Timeout', description: 'Auto-logout after 30 minutes of inactivity', enabled: true },
                { label: 'Data Sharing', description: 'Share analytics with partners', enabled: false },
            ],
        },
        {
            title: 'Preferences',
            icon: Palette,
            items: [
                { label: 'Compact Mode', description: 'Show more content on screen', enabled: false },
                { label: 'Show Tooltips', description: 'Display helpful hints and tips', enabled: true },
                { label: 'Auto-save', description: 'Automatically save your work', enabled: true },
            ],
        },
    ];

    return (
        <div className="p-8">
            <div className="max-w-4xl mx-auto space-y-8">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                        Settings
                    </h1>
                    <p className="text-gray-600 dark:text-gray-400">
                        Manage your account settings and preferences
                    </p>
                </div>

                {settingsSections.map((section, sectionIndex) => {
                    const Icon = section.icon;
                    return (
                        <div key={sectionIndex} className="card p-6">
                            <div className="flex items-center gap-3 mb-6">
                                <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
                                    <Icon className="text-primary" size={20} />
                                </div>
                                <h2 className="text-xl font-bold text-gray-900 dark:text-white">
                                    {section.title}
                                </h2>
                            </div>

                            <div className="space-y-4">
                                {section.items.map((item, itemIndex) => (
                                    <div
                                        key={itemIndex}
                                        className="flex items-center justify-between p-4 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                                    >
                                        <div className="flex-1">
                                            <p className="font-semibold text-gray-900 dark:text-white mb-1">
                                                {item.label}
                                            </p>
                                            <p className="text-sm text-gray-500 dark:text-gray-400">
                                                {item.description}
                                            </p>
                                        </div>
                                        <button
                                            className={`relative w-14 h-8 rounded-full transition-all duration-300 ${item.enabled ? 'bg-primary' : 'bg-gray-300 dark:bg-gray-600'
                                                }`}
                                        >
                                            <span
                                                className={`absolute top-1 left-1 w-6 h-6 bg-white rounded-full transition-all duration-300 ${item.enabled ? 'translate-x-6' : 'translate-x-0'
                                                    }`}
                                            />
                                        </button>
                                    </div>
                                ))}
                            </div>
                        </div>
                    );
                })}

                {/* Danger Zone */}
                <div className="card p-6 border-2 border-red-200 dark:border-red-900/50">
                    <h2 className="text-xl font-bold text-red-600 dark:text-red-400 mb-4">
                        Danger Zone
                    </h2>
                    <div className="space-y-4">
                        <div className="p-4 rounded-xl bg-red-50 dark:bg-red-900/10">
                            <h3 className="font-semibold text-gray-900 dark:text-white mb-2">
                                Delete Account
                            </h3>
                            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
                                Once you delete your account, there is no going back. Please be certain.
                            </p>
                            <button className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
                                Delete My Account
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Settings;
