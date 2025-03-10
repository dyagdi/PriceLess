class SavedAddress {
  final String id;
  final String name;
  final String address;
  final bool isDefault;

  SavedAddress({
    required this.id,
    required this.name,
    required this.address,
    this.isDefault = false,
  });
}
