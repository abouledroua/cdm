class Artisan {
  String nom, tel, adress, photo, email, facebook, des_ar, designation;
  int etat, idArtisan, idSpecialite, wilaya, rate;
  Artisan(
      {required this.idArtisan,
      required this.etat,
      required this.nom,
      required this.des_ar,
      required this.designation,
      required this.idSpecialite,
      required this.wilaya,
      required this.adress,
      required this.rate,
      required this.tel,
      required this.photo,
      required this.facebook,
      required this.email});
}
