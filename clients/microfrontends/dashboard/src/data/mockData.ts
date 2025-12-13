export const mockKPIData = {
    totalRevenue: {
        value: 245789,
        change: 20.1,
        label: 'Total Revenue',
    },
    activeUsers: {
        value: 12543,
        change: 15.3,
        label: 'Active Users',
    },
    conversionRate: {
        value: 3.24,
        change: -2.4,
        label: 'Conversion Rate',
        suffix: '%',
    },
    avgSessionTime: {
        value: 8.5,
        change: 12.1,
        label: 'Avg Session Time',
        suffix: 'min',
    },
};

export const mockRevenueData = [
    { month: 'Jan', revenue: 32000, users: 1200 },
    { month: 'Feb', revenue: 41000, users: 1600 },
    { month: 'Mar', revenue: 35000, users: 1400 },
    { month: 'Apr', revenue: 51000, users: 1900 },
    { month: 'May', revenue: 49000, users: 2100 },
    { month: 'Jun', revenue: 62000, users: 2300 },
    { month: 'Jul', revenue: 69000, users: 2800 },
];

export const mockUsers = [
    {
        id: 1,
        name: 'Emma Johnson',
        email: 'emma.johnson@example.com',
        role: 'Admin',
        status: 'active',
        lastActive: '2 minutes ago',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emma',
    },
    {
        id: 2,
        name: 'Michael Chen',
        email: 'michael.chen@example.com',
        role: 'User',
        status: 'active',
        lastActive: '1 hour ago',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Michael',
    },
    {
        id: 3,
        name: 'Sarah Williams',
        email: 'sarah.w@example.com',
        role: 'User',
        status: 'inactive',
        lastActive: '2 days ago',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah',
    },
    {
        id: 4,
        name: 'David Martinez',
        email: 'david.m@example.com',
        role: 'Manager',
        status: 'active',
        lastActive: '30 minutes ago',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=David',
    },
    {
        id: 5,
        name: 'Jessica Brown',
        email: 'jessica.brown@example.com',
        role: 'User',
        status: 'active',
        lastActive: '5 hours ago',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jessica',
    },
];
