class FormData {
  final String roleName;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String currentCity;
  final String experience;
  final String bio;
  final String whyApply;
  final String expectationFromRole;
  final String resume;
  final List<String> links;
  final String form = "669f5dffe97ef3e1cf4affa8";

  FormData({
    required this.roleName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.currentCity,
    required this.experience,
    required this.bio,
    required this.whyApply,
    required this.expectationFromRole,
    required this.resume,
    required this.links,
  }) {
    if (!resume.startsWith('data:application/')) {
      throw FormatException('Invalid resume format');
    }
  }

  Map<String, dynamic> toJson() {
    final cleanedLinks = links.where((link) => link.isNotEmpty).toList();
    
    return {
      "roleName": roleName.trim(),
      "firstName": firstName.trim(),
      "lastName": lastName.trim(),
      "email": email.trim(),
      "phoneNumber": phoneNumber.trim(),
      "currentCity": currentCity.trim(),
      "experience": experience.trim(),
      "bio": bio.trim(),
      "whyApply": whyApply.trim(),
      "expectationFromRole": expectationFromRole.trim(),
      "resume": resume,
      "links": cleanedLinks.isEmpty ? [''] : cleanedLinks,
      "form": form,
    };
  }

  @override
  String toString() {
    return 'FormData(roleName: $roleName, firstName: $firstName, lastName: $lastName, '
        'email: $email, phoneNumber: $phoneNumber, currentCity: $currentCity, '
        'experience: $experience, bio: $bio, whyApply: $whyApply, '
        'expectationFromRole: $expectationFromRole, resume: ${resume.length}, '
        'links: $links, form: $form)';
  }
}
