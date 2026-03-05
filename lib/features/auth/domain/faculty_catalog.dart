class FacultyCatalog {
  FacultyCatalog._();

  static const List<String> faculties = [
    'Faculty of Nursing and Allied Health Sciences (FNAHS)',
    'Faculty of Agriculture and Life Sciences (FALS)',
    'Faculty of Business and Management (FBM)',
    'Faculty of Computing, Engineering and Technology (FaCET)',
    'Faculty of Teacher Education (FTED)',
    'Faculty of Humanities, Social Sciences, and Communication (FHuSoCom)',
    'Faculty of Criminal Justice Education (FCJE)',
  ];

  static const Map<String, List<String>> programsByFaculty = {
    'Faculty of Nursing and Allied Health Sciences (FNAHS)': [
      'Bachelor of Science in Nursing',
    ],
    'Faculty of Agriculture and Life Sciences (FALS)': [
      'Bachelor of Science in Agribusiness Management',
      'Bachelor of Agricultural Technology',
      'Bachelor of Science in Biology',
      'Bachelor of Science in Environmental Science',
    ],
    'Faculty of Business and Management (FBM)': [
      'Bachelor of Science in Business Administration',
      'Bachelor of Science in Criminology',
      'Bachelor of Science in Hospitality Management',
    ],
    'Faculty of Computing, Engineering and Technology (FaCET)': [
      'Bachelor of Science in Civil Engineering',
      'Bachelor of Industrial Technology Management',
      'Bachelor of Science in Information Technology',
      'Bachelor of Science in Mathematics with Research Statistics',
    ],
    'Faculty of Teacher Education (FTED)': [
      'Bachelor of Elementary Education',
      'Bachelor of Early Childhood Education',
      'Bachelor of Secondary Education major in Biological Sciences',
      'Bachelor of Secondary Education major in English',
      'Bachelor of Secondary Education major in Filipino',
      'Bachelor of Secondary Education major in Mathematics',
      'Bachelor of Secondary Education major in Science',
      'Bachelor of Physical Education major in School Physical Education',
      'Bachelor of Special Needs Education',
    ],
    'Faculty of Criminal Justice Education (FCJE)': [
      'Bachelor of Science in Criminology',
    ],
    'Faculty of Humanities, Social Sciences, and Communication (FHuSoCom)': [
      'Bachelor of Development Communication',
      'Bachelor of Arts in Political Science',
      'Bachelor of Science in Psychology',
    ],
  };
}
