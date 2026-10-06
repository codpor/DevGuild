// lib/constants/app_strings.dart
// Sentralisasi semua string UI agar mudah dikelola dan dilokalisasi

class AppStrings {
  AppStrings._();

  // ── App ──
  static const appName = 'DevGuild';
  static const appTagline = 'Inkubator Karya & Klinik Kode PPLG';

  // ── Auth ──
  static const login = 'Masuk';
  static const register = 'Daftar';
  static const registerNow = 'Daftar Sekarang';
  static const logout = 'Keluar';
  static const logoutConfirm = 'Apakah kamu yakin ingin keluar dari akun ini?';
  static const logoutConfirmGuru = 'Apakah Anda yakin ingin keluar dari akun ini?';
  static const yesLogout = 'Ya, Keluar';
  static const cancel = 'Batal';
  static const nisLabel = 'NIS';
  static const passwordLabel = 'Password';
  static const confirmPasswordLabel = 'Konfirmasi Password';
  static const nameLabel = 'Nama Lengkap';
  static const kelasLabel = 'Kelas';
  static const noAccount = 'Belum punya akun? ';
  static const hasAccount = 'Sudah punya akun? ';
  static const createAccount = 'Buat akun baru';
  static const demoLogin = 'Demo Login';
  static const demoLoginSiswa = 'Siswa: NIS 2201 | pw: password123';
  static const demoLoginGuru = 'Guru: NIS 9999 | pw: admin123';

  // ── Auth Errors ──
  static const loginFailed = 'NIS atau Password salah!';
  static const nisAlreadyRegistered = 'NIS sudah terdaftar!';
  static const allFieldsRequired = 'Semua field wajib diisi!';

  // ── Validation ──
  static const nisRequired = 'NIS wajib diisi';
  static const nisNumericOnly = 'NIS harus berupa angka';
  static const nisMinLength = 'NIS minimal 4 digit';
  static const passwordRequired = 'Password wajib diisi';
  static const passwordMinLength = 'Password minimal 6 karakter';
  static const confirmPasswordRequired = 'Konfirmasi password wajib diisi';
  static const passwordMismatch = 'Password tidak cocok';
  static const nameRequired = 'Nama wajib diisi';
  static const nameMinLength = 'Nama minimal 3 karakter';
  static const fieldRequired = 'wajib diisi';

  // ── Navigation Labels ──
  static const showcase = 'Showcase';
  static const showcaseKarya = 'Showcase Karya';
  static const clinic = 'Klinik';
  static const clinicKode = 'Klinik Kode';
  static const leaderboard = 'Peringkat';
  static const leaderboardMentor = 'Peringkat Mentor';
  static const profile = 'Profil';
  static const dashboard = 'Dashboard';
  static const adminDashboard = 'Admin Dashboard';
  static const students = 'Siswa';
  static const validation = 'Validasi';
  static const monitoring = 'Monitoring';
  static const monitoringClinic = 'Monitoring Klinik';

  // ── Ticket ──
  static const createTicket = 'Buat Tiket';
  static const createTicketNew = 'Buat Tiket Baru';
  static const sendTicket = 'Kirim Tiket';
  static const ticketDetail = 'Detail Tiket';
  static const ticketTitle = 'Judul Error';
  static const ticketDescription = 'Deskripsi Masalah';
  static const ticketErrorCode = 'Pesan Error (opsional)';
  static const ticketErrorHint = 'Paste error message disini...';
  static const ticketCategory = 'Kategori';
  static const ticketCreated = 'Tiket berhasil dibuat!';
  static const ticketNoResult = 'Tidak ada tiket ditemukan';
  static const ticketSearch = 'Cari tiket error...';
  static const ticketReply = 'Tulis balasan...';
  static const ticketNoReplies = 'Belum ada balasan. Jadilah yang pertama!';
  static const ticketMarkSolved = 'Tandai Solved';
  static const ticketBestAnswer = '✓ Jawaban Terbaik';
  static const ticketEditTitle = 'Edit Judul Tiket';
  static const ticketNewTitle = 'Judul Baru';
  static const ticketTitleUpdated = 'Judul tiket diperbarui';
  static const ticketCloseByMod = 'Tiket ditutup oleh Moderator';
  static const ticketCloseSolved = 'Tutup Tiket (Solved)';
  static const ticketReplyDeleted = 'Balasan dihapus';
  static const ticketOnlyMentorReply =
      'Hanya Mentor/Moderator yang dapat menjawab tiket';
  static const save = 'Simpan';

  // ── Ticket Status ──
  static const statusAll = 'Semua';
  static const statusOpen = 'Terbuka';
  static const statusInProgress = 'Diproses';
  static const statusSolved = 'Solved';

  // ── Ticket Categories ──
  static const catPhpMysql = 'PHP & MySQL';
  static const catHtmlCss = 'HTML & CSS';
  static const catJavascript = 'JavaScript';
  static const catPython = 'Python';
  static const catWebSecurity = 'Keamanan Web';
  static const catGeneral = 'Umum';

  static const List<String> ticketCategories = [
    catPhpMysql,
    catHtmlCss,
    catJavascript,
    catPython,
    catWebSecurity,
    catGeneral,
  ];

  // ── Project ──
  static const uploadProject = 'Upload Karya';
  static const submitProject = 'Submit Karya';
  static const projectName = 'Nama Karya';
  static const projectDescription = 'Deskripsi';
  static const projectLinkAccess = 'Link Akses / Demo (opsional)';
  static const projectLinkGithub = 'Link Repository / GitHub (opsional)';
  static const projectTech = 'Teknologi yang Digunakan';
  static const projectTechHint = 'PHP, MySQL, Bootstrap';
  static const projectTeam = 'Tim Pengembang';
  static const projectTeamHint = 'Nama1, Nama2, Nama3';
  static const projectReviewNote =
      'Karya akan direview oleh guru sebelum ditampilkan.';
  static const projectSubmitted =
      'Karya berhasil disubmit! Menunggu validasi guru.';
  static const projectNoValidated = 'Belum ada karya yang divalidasi';
  static const projectDetail = 'Detail Karya';
  static const projectValidated = 'Tervalidasi';
  static const projectTechnology = 'Teknologi';
  static const projectLinkDemo = 'Link Akses / Demo';
  static const projectRepository = 'Repository';
  static const projectTeamDev = 'Tim Pengembang';
  static const projectCreatedBy = 'Dibuat oleh';
  static const projectGuruNotes = 'Catatan Guru';
  static const projectLinkCopied = 'Link disalin ke clipboard!';
  static const projectPhotoUpload = 'Tap untuk upload screenshot';
  static const projectPhotoNote = '(Fitur photo: perlu Firebase Storage)';

  static const List<String> projectCategories = [
    'Web App',
    'Web',
    catPython,
    catJavascript,
    'Mobile',
    'Lainnya',
  ];

  // ── Profile ──
  static const activeMode = 'Mode Aktif Saya';
  static const activeModeDesc =
      'Ganti peran sesuai yang ingin kamu lakukan sekarang.';
  static const badgesTitle = 'Badge & Pencapaian';
  static const noBadges = 'Belum ada badge';
  static const recentActivity = 'Aktivitas Terbaru';
  static const noActivity = 'Belum ada aktivitas';
  static const ticketCreatedLabel = 'Tiket\nDibuat';
  static const ticketAnsweredLabel = 'Tiket\nDijawab';
  static const totalPoin = 'Total\nPoin';
  static const poin = 'poin';

  // ── Role ──
  static const mentee = 'Mentee';
  static const mentor = 'Mentor';
  static const moderator = 'Moderator';
  static const menteeDesc = 'Bertanya';
  static const mentorDesc = 'Menjawab';
  static const moderatorDesc = 'Mengawasi';
  static const mentorMode = '🎓 Mentor Mode';
  static const moderatorMode = '🛡️ Moderator Mode';
  static const requirements = 'Persyaratan:';
  static const requirementsNotMet =
      'Kamu belum memenuhi semua persyaratan. Terus berkontribusi untuk memenuhinya!';
  static const requirementsMet =
      'Semua persyaratan terpenuhi! Permohonanmu akan dikirim ke guru untuk disetujui.';
  static const close = 'Tutup';
  static const pendingRequestExists =
      'Kamu sudah memiliki permohonan yang sedang diproses.';

  static String beRole(String role) => 'Menjadi $role';
  static String roleRequestSent(String role) =>
      'Permohonan menjadi $role berhasil dikirim! Menunggu persetujuan guru.';
  static String roleRequestPending(String role) =>
      'Permohonan menjadi $role sedang menunggu persetujuan guru.';
  static String submitRoleRequest(String role) =>
      'Ajukan Permohonan $role';

  // ── Guru Dashboard ──
  static String greetingGuru(String name) => 'Halo, $name! 👋';
  static const ecosystemSummary = 'Ringkasan Ekosistem';
  static String schoolYear(int year) => 'SMK PPLG · $year';
  static const activeSiswa = 'Siswa Aktif';
  static const totalKarya = 'Karya Total';
  static const highestPoin = 'Poin Tertinggi';
  static const needsAction = 'Perlu Tindakan';
  static const pendingKarya = 'Karya Pending';
  static const waitingValidation = 'Menunggu validasi';
  static const openTickets = 'Tiket Terbuka';
  static const noAnswer = 'Belum ada jawaban';
  static const roleRequestTitle = 'Permohonan Role';
  static const waitingApproval = 'Menunggu persetujuan';
  static const topMentor = 'Top Mentor';

  // ── Guru Manajemen ──
  static const studentManagement = 'Manajemen Siswa';
  static const studentList = 'Daftar Siswa';
  static const roleRequests = 'Permohonan Role';
  static String totalStudents(int count) => 'Total $count Siswa Terdaftar';
  static const viewDetail = 'Lihat Detail';
  static const resetPassword = 'Reset Password';
  static const deactivateAccount = 'Nonaktifkan Akun';
  static const waitingApprovalBadge = '⏳ Menunggu Persetujuan';
  static const noRoleRequests = 'Tidak ada permohonan role baru';
  static const reject = 'Tolak';
  static const approve = 'Setujui';
  static const rejectionReason = 'Alasan Penolakan';
  static const rejectionHint = 'Berikan feedback untuk siswa...';
  static const rejectRequest = 'Tolak Permohonan';
  static const requestRejected = 'Permohonan ditolak';
  static String approvedAs(String name, String role) =>
      '$name disetujui sebagai $role!';
  static const historyLabel = 'Riwayat';

  // ── Guru Validasi ──
  static const validateKarya = 'Validasi Karya';
  static const allValidated = 'Semua karya sudah divalidasi!';
  static const noApprovedKarya = 'Belum ada karya disetujui';
  static const waitingReview = '⏳ Menunggu Review';
  static const rejectKarya = 'Tolak Karya';
  static const rejectionReasonRequired = 'Alasan Penolakan *';
  static const rejectionKaryaHint =
      'Berikan catatan agar siswa bisa memperbaiki...';
  static const fillRejectionReason = 'Mohon isi alasan penolakan';
  static const karyaApproved = 'Karya disetujui & masuk Showcase!';
  static const karyaRejected = 'Karya ditolak dengan catatan';

  // ── Guru Monitoring ──
  static const needsAttention = 'Perlu Perhatian — Belum Ada Jawaban';
  static const beingProcessed = 'Sedang Diproses';
  static const resolved = 'Sudah Terselesaikan';

  // ── Activities ──
  static const activityCreateTicket = 'Membuat Tiket';
  static const activityReplyTicket = 'Menjawab Tiket';
  static const activityUploadProject = 'Upload Karya';

  // ── Error Messages ──
  static const errorGeneral = 'Terjadi kesalahan. Silakan coba lagi.';
  static const errorConnection = 'Gagal terhubung ke server.';

  // ── Kelas ──
  static const List<String> kelasList = [
    'X PPLG 1',
    'X PPLG 2',
    'XI PPLG 1',
    'XI PPLG 2',
    'XII PPLG 1',
    'XII PPLG 2',
  ];
}
