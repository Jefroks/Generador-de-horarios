class AppVersions {
  const AppVersions._();

  /// Cambia este valor en builds manuales cuando publiques un nuevo JSON.
  /// En GitHub Actions se recomienda inyectarlo con:
  /// --dart-define=SEED_DATA_VERSION=${{ github.sha }}
  static const String seedDataVersion = String.fromEnvironment(
    'SEED_DATA_VERSION',
    defaultValue: 'local-cachefix-1',
  );

  /// Archivo JSON público servido desde la carpeta web/.
  /// En producción queda disponible como /data/professors_seed.json
  /// respetando el base href del sitio.
  static const String seedFilePath = 'data/professors_seed.json';
}
