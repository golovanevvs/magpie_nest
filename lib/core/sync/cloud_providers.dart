library;

class CloudProvider {
  final String name;
  final String url;

  const CloudProvider({required this.name, required this.url});
}

const cloudProviders = <CloudProvider>[
  CloudProvider(name: 'Yandex.Disk', url: 'https://webdav.yandex.ru/'),
  CloudProvider(name: 'Cloud Mail.ru', url: 'https://webdav.cloud.mail.ru/'),
  CloudProvider(name: 'pCloud', url: 'https://webdav.pcloud.com/'),
];

const kCustomCloudProvider = 'Custom';
