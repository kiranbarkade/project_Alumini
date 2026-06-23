const dns = require('dns');
dns.setServers(['8.8.8.8', '8.8.4.4']);

const mongoose = require('mongoose');
const dotenv = require('dotenv');

const path = require('path');

// Load env vars (try local backend/.env first, then parent project root .env)
dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../../.env') });

// Load models
const User = require('../models/User');
const Job = require('../models/Job');
const Referral = require('../models/Referral');
const Mentorship = require('../models/Mentorship');
const Post = require('../models/Post');
const Notification = require('../models/Notification');
const Message = require('../models/Message');

// Connect to DB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/careerbridge');

const importData = async () => {
  try {
    // Clear existing collections
    await User.deleteMany();
    await Job.deleteMany();
    await Referral.deleteMany();
    await Mentorship.deleteMany();
    await Post.deleteMany();
    await Notification.deleteMany();
    await Message.deleteMany();

    console.log('Database cleared...');

    // 1. Create Users
    const users = await User.create([
      {
        name: 'Dr. Sandeep Poddar',
        email: 'placement.cell@zeal.edu.in',
        password: 'password123',
        role: 'admin',
        college: 'Zeal College of Engineering and Research',
        branch: 'Training & Placement Cell',
        graduationYear: 2012,
        skills: ['Career Guidance', 'Industrial Relations', 'Resume Review', 'Corporate Partnerships'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=sandeep',
        linkedinUrl: 'https://linkedin.com/in/sandeep-poddar',
        about: 'Head of Training & Placement Cell, Zeal College of Engineering. Supporting student careers since 2012.'
      },
      {
        name: 'Anjali Sharma',
        email: 'anjali.sharma@google.com',
        password: 'password123',
        role: 'alumni',
        college: 'Zeal College of Engineering and Research',
        branch: 'Computer Engineering',
        graduationYear: 2022,
        company: 'Google',
        designation: 'Software Engineer III',
        skills: ['Flutter', 'Dart', 'Go', 'Kubernetes', 'System Design'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=anjali',
        linkedinUrl: 'https://linkedin.com/in/anjali-sharma-zeal',
        about: 'Software Engineer III at Google, Munich. Graduated from Zeal (CS Branch) in 2022. Passionate about Flutter and cloud scale engineering.',
        isVerified: true
      },
      {
        name: 'Rohan Deshmukh',
        email: 'rohan.deshmukh@tesla.com',
        password: 'password123',
        role: 'alumni',
        college: 'Zeal College of Engineering and Research',
        branch: 'Mechanical Engineering',
        graduationYear: 2021,
        company: 'Tesla',
        designation: 'Senior Design Engineer',
        skills: ['SolidWorks', 'Ansys', 'EV Design', 'CFD Analysis'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=rohan',
        linkedinUrl: 'https://linkedin.com/in/rohan-deshmukh-tesla',
        about: 'Senior Design Engineer at Tesla. Zeal Mechanical 2021 Passout. Specialist in electric vehicle powertrains and thermal systems.',
        isVerified: true
      },
      {
        name: 'Yuraj Patil',
        email: 'yuraj.patil.comp23@zeal.edu.in',
        password: 'password123',
        role: 'student',
        college: 'Zeal College of Engineering and Research',
        branch: 'Computer Engineering',
        graduationYear: 2027,
        skills: ['Dart', 'Flutter', 'Firebase', 'Java', 'Node.js'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=yuraj',
        linkedinUrl: 'https://linkedin.com/in/yuraj-patil',
        resumeUrl: 'https://zeal-portal.web.app/resumes/yuraj_patil.pdf',
        about: 'Pre-final year Computer Engineering student at Zeal. Learning Flutter app development and backend frameworks.'
      },
      {
        name: 'Amit Verma',
        email: 'amit.verma@wipro.com',
        password: 'password123',
        role: 'alumni',
        college: 'Zeal College of Engineering and Research',
        branch: 'Information Technology',
        graduationYear: 2020,
        company: 'Wipro',
        designation: 'Tech Lead',
        skills: ['Java', 'Spring Boot', 'Microservices', 'AWS', 'SQL'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=amit',
        linkedinUrl: 'https://linkedin.com/in/amit-verma-wipro',
        about: 'Tech Lead at Wipro. Zeal IT 2020 Graduate. Mentor for backend technologies and enterprise systems.',
        isVerified: true
      },
      {
        name: 'Neha Dixit',
        email: 'neha.dixit@flipkart.com',
        password: 'password123',
        role: 'alumni',
        college: 'Zeal College of Engineering and Research',
        branch: 'Computer Engineering',
        graduationYear: 2019,
        company: 'Flipkart',
        designation: 'Senior Product Manager',
        skills: ['Product Roadmap', 'Agile', 'Fintech', 'Mobile UX', 'SQL'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=neha',
        linkedinUrl: 'https://linkedin.com/in/neha-dixit-flipkart',
        about: 'Senior Product Manager at Flipkart. Graduated from Zeal (CS) in 2019. Passionate about Fintech and customer-centric products.',
        isVerified: true
      },
      {
        name: 'Priya Patel',
        email: 'priya.patel.comp24@zeal.edu.in',
        password: 'password123',
        role: 'student',
        college: 'Zeal College of Engineering and Research',
        branch: 'Computer Engineering',
        graduationYear: 2028,
        skills: ['React', 'JavaScript', 'HTML/CSS', 'Node.js'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=priya',
        linkedinUrl: 'https://linkedin.com/in/priya-patel-zeal',
        about: 'Second year Computer Engineering student at Zeal. Enthusiastic about web development and UI/UX design.'
      },
      {
        name: 'Rahul Sharma',
        email: 'rahul.sharma.mech23@zeal.edu.in',
        password: 'password123',
        role: 'student',
        college: 'Zeal College of Engineering and Research',
        branch: 'Mechanical Engineering',
        graduationYear: 2026,
        skills: ['SolidWorks', 'MATLAB', 'Python', 'AutoCAD'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=rahul',
        linkedinUrl: 'https://linkedin.com/in/rahul-sharma-mech',
        about: 'Final year Mechanical Engineering student at Zeal. Working on EV chassis design for national level competition.'
      }
    ]);

    const admin = users[0];
    const alumniAnjali = users[1];
    const alumniRohan = users[2];
    const studentYuraj = users[3];
    const alumniAmit = users[4];
    const alumniNeha = users[5];
    const studentPriya = users[6];
    const studentRahul = users[7];

    console.log('Users seeded...');

    // 2. Create Jobs
    const jobs = await Job.create([
      {
        title: 'Flutter Developer Intern',
        company: 'Cognizant',
        location: 'Pune (Hinjewadi) / Hybrid',
        type: 'internship',
        description: 'Cognizant is hiring Flutter developer interns to join our mobile solutions lab. You will build, test, and ship features for next-gen IoT enterprise apps.',
        postedBy: admin._id,
        skillsRequired: ['Flutter', 'Dart', 'Git', 'REST APIs'],
        salary: '₹25,000 / month'
      },
      {
        title: 'Software Development Engineer - I',
        company: 'Google',
        location: 'Bengaluru / Remote',
        type: 'referral',
        description: 'I am happy to refer qualified Zeal juniors for the SDE-1 backend developer role at Google India. This role focuses on backend systems in Go/Java.',
        postedBy: alumniAnjali._id,
        skillsRequired: ['DSA', 'Java', 'Go', 'SQL'],
        salary: '₹18 - ₹22 LPA'
      },
      {
        title: 'Graduate Engineer Trainee',
        company: 'Tesla',
        location: 'Pune / Onsite',
        type: 'fulltime',
        description: 'Tesla is seeking graduate mechanical engineers for powertrain testing, quality assurance, and assembly operations in Pune plant.',
        postedBy: alumniRohan._id,
        skillsRequired: ['SolidWorks', 'CFD', 'EV Design'],
        salary: '₹12 - ₹15 LPA'
      },
      {
        title: 'SDE Intern',
        company: 'Flipkart',
        location: 'Bengaluru / Hybrid',
        type: 'internship',
        description: 'Flipkart is hiring Software Development Engineer Interns. You will work with the core checkout team to optimize loading speed and transaction pipelines.',
        postedBy: alumniNeha._id,
        skillsRequired: ['Node.js', 'React', 'Data Structures', 'SQL'],
        salary: '₹40,000 / month'
      },
      {
        title: 'Java Backend Developer',
        company: 'Wipro',
        location: 'Pune / Hybrid',
        type: 'referral',
        description: 'Wipro is looking for Java backend developers to build scalable enterprise banking modules. I will refer candidates who clear the technical round.',
        postedBy: alumniAmit._id,
        skillsRequired: ['Java', 'Spring Boot', 'REST APIs', 'SQL'],
        salary: '₹6.5 - ₹8 LPA'
      }
    ]);

    const jobFlutter = jobs[0];
    const jobGoogle = jobs[1];
    const jobTesla = jobs[2];
    const jobFlipkart = jobs[3];
    const jobWipro = jobs[4];

    console.log('Jobs seeded...');

    // 3. Create Posts
    const posts = await Post.create([
      {
        userId: alumniAnjali._id,
        content: 'Super thrilled to share that I have joined Google Munich as a Software Engineer III! 🇩🇪✈️\n\nHuge thanks to my professors at Zeal College of Engineering who supported my projects, and the Training & Placement Cell for organizing early campus opportunities. To my juniors: Keep coding, stay consistent with DSA, and build real-world products!',
        image: 'https://images.unsplash.com/photo-1573164713988-8665fc963095?auto=format&fit=crop&w=800&q=80',
        tags: ['#Referral', '#Placement'],
        company: 'Google',
        likes: [studentYuraj._id, admin._id],
        comments: [
          {
            userId: studentYuraj._id,
            userName: studentYuraj.name,
            userImage: studentYuraj.profileImage,
            content: 'Congratulations Anjali! You inspire all of us. Hope to connect soon!',
            createdAt: new Date(Date.now() - 3600000 * 3)
          },
          {
            userId: admin._id,
            userName: admin.name,
            userImage: admin.profileImage,
            content: 'Well deserved, Anjali! We are extremely proud of your achievements.',
            createdAt: new Date(Date.now() - 3600000 * 2)
          }
        ],
        createdAt: new Date(Date.now() - 3600000 * 4)
      },
      {
        userId: admin._id,
        content: '📢 IMPORTANT ANNOUNCEMENT for final year CS/IT/E&TC students:\n\nCognizant GenC campus recruitment drive begins on June 20th. Registrations close this Saturday. Please update your profile fields (especially CGPA, skills, and resume) in the CareerBridge Portal so recruiters can shortlist you directly. All the best!',
        tags: ['#Job', '#Placement'],
        company: 'Cognizant',
        likes: [studentYuraj._id],
        comments: [],
        createdAt: new Date(Date.now() - 3600000 * 20)
      },
      {
        userId: alumniRohan._id,
        content: 'My Interview Experience at Tesla for Design Engineer:\n\nRound 1: Technical screening (Deep dive into FEA & SolidWorks design rules).\nRound 2: Systems Design (Design of battery pack enclosure cooling).\nRound 3: Leadership/Behavioral (Discussed conflict resolution in college team projects).\n\n💡 Pro tip: Focus on first-principles physics! Don\'t just learn tools, understand the mechanical physics behind calculations.',
        image: 'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=800&q=80',
        tags: ['#Placement'],
        company: 'Tesla',
        likes: [studentYuraj._id],
        comments: [],
        createdAt: new Date(Date.now() - 3600000 * 48)
      },
      {
        userId: alumniNeha._id,
        content: "Excited to share that we just launched Flipkart's new simplified UPI payment dashboard! 🚀💳\n\nBuilding fintech systems at this scale requires deep focus on latency and API reliability. For students looking to get into product management: understand user flow, ask 'why' at every stage, and learn how to read SQL logs. Feel free to reach out for mock interviews or product teardown sessions!",
        image: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=800&q=80',
        tags: ['#Job', '#Internship'],
        company: 'Flipkart',
        likes: [studentPriya._id, studentYuraj._id],
        comments: [],
        createdAt: new Date(Date.now() - 3600000 * 12)
      },
      {
        userId: alumniAmit._id,
        content: "Had an amazing session today mentoring final year Zeal IT students on Microservices & Cloud patterns. ☁️💻\n\nIt is great to see the enthusiasm of our juniors. My advice to anyone preparing for service/product placements: get your database fundamentals solid. Don't skip indexes, normalizations, and transaction locks. All the best!",
        image: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
        tags: ['#Referral', '#Placement'],
        company: 'Wipro',
        likes: [studentRahul._id, studentYuraj._id],
        comments: [],
        createdAt: new Date(Date.now() - 3600000 * 6)
      }
    ]);

    console.log('Posts seeded...');

    // 4. Create Referrals
    const referral1 = await Referral.create({
      studentId: studentYuraj._id,
      alumniId: alumniAnjali._id,
      jobId: jobGoogle._id,
      message: 'Hi Anjali, I have built several projects using Flutter and Node.js. My resume is updated. I would be highly obliged if you could refer me for the SDE-1 role. Thank you!',
      status: 'pending'
    });

    const referral2 = await Referral.create({
      studentId: studentPriya._id,
      alumniId: alumniNeha._id,
      jobId: jobFlipkart._id,
      message: 'Hi Neha, I have been building full stack web projects and love Flipkart\'s tech stack. I would appreciate if you could refer me for the SDE Intern role. Thanks!',
      status: 'accepted'
    });

    const referral3 = await Referral.create({
      studentId: studentYuraj._id,
      alumniId: alumniAmit._id,
      jobId: jobWipro._id,
      message: 'Hi Amit sir, I am Yuraj from Zeal CS. I have basic Java knowledge and want to apply for the Java Backend Developer position. Please guide or refer me. Thanks!',
      status: 'pending'
    });

    console.log('Referrals seeded...');

    // 5. Create Mentorships
    const mentorships = await Mentorship.create([
      {
        studentId: studentYuraj._id,
        alumniId: alumniAnjali._id,
        topic: 'Resume Review and Off-Campus Strategies',
        date: new Date(Date.now() + 3600000 * 24 * 3),
        timeSlot: '7:30 PM - 8:00 PM',
        status: 'approved',
        notes: 'Looking forward to meeting you! Please have your GitHub profile links ready.'
      },
      {
        studentId: studentYuraj._id,
        alumniId: alumniRohan._id,
        topic: 'EV Design Simulation Guidelines',
        date: new Date(Date.now() - 3600000 * 24 * 10),
        timeSlot: '6:00 PM - 6:45 PM',
        status: 'completed',
        notes: 'Completed discussion on FEA simulation practices.'
      },
      {
        studentId: studentPriya._id,
        alumniId: alumniNeha._id,
        topic: 'Product Management 101 for Engineers',
        date: new Date(Date.now() + 3600000 * 24 * 5),
        timeSlot: '5:00 PM - 5:30 PM',
        status: 'approved',
        notes: 'Please review a product teardown before the session.'
      },
      {
        studentId: studentYuraj._id,
        alumniId: alumniAmit._id,
        topic: 'Mock Interview: Java and Spring Boot',
        date: new Date(Date.now() + 3600000 * 24 * 2),
        timeSlot: '6:30 PM - 7:00 PM',
        status: 'pending',
        notes: 'Be prepared with OOP design principles.'
      }
    ]);

    console.log('Mentorship sessions seeded...');

    // 6. Create Notifications
    await Notification.create([
      {
        recipient: alumniAnjali._id,
        sender: studentYuraj._id,
        type: 'referral',
        message: 'Yuraj Patil requested a referral for the position of "Software Development Engineer - I" at "Google"',
        referenceId: referral1._id.toString()
      },
      {
        recipient: studentYuraj._id,
        sender: alumniAnjali._id,
        type: 'mentorship',
        message: 'Your mentorship request on "Resume Review and Off-Campus Strategies" has been approved by Anjali Sharma',
        referenceId: mentorships[0]._id.toString()
      },
      {
        recipient: alumniNeha._id,
        sender: studentPriya._id,
        type: 'referral',
        message: 'Priya Patel requested a referral for the position of "SDE Intern" at "Flipkart"',
        referenceId: referral2._id.toString()
      },
      {
        recipient: studentPriya._id,
        sender: alumniNeha._id,
        type: 'referral',
        message: 'Your referral request for "SDE Intern" at "Flipkart" has been approved by Neha Dixit',
        referenceId: referral2._id.toString()
      },
      {
        recipient: alumniAmit._id,
        sender: studentYuraj._id,
        type: 'referral',
        message: 'Yuraj Patil requested a referral for the position of "Java Backend Developer" at "Wipro"',
        referenceId: referral3._id.toString()
      }
    ]);

    console.log('Notifications seeded...');

    // 7. Create Messages
    await Message.create([
      {
        senderId: studentYuraj._id,
        receiverId: alumniAnjali._id,
        message: 'Hi Anjali, I saw your post about Google Munich! Can we connect for mentorship?',
        createdAt: new Date(Date.now() - 3600000 * 2)
      },
      {
        senderId: alumniAnjali._id,
        receiverId: studentYuraj._id,
        message: "Hi Yuraj, sure! I'd love to help. Have you checked out my SDE-1 referral listing?",
        createdAt: new Date(Date.now() - 3600000 * 1.8)
      },
      {
        senderId: studentYuraj._id,
        receiverId: alumniAnjali._id,
        message: 'Yes, I requested a referral just now. I will prepare my resume as well.',
        createdAt: new Date(Date.now() - 3600000 * 1.5)
      },
      {
        senderId: studentPriya._id,
        receiverId: alumniNeha._id,
        message: "Hi Neha, I'm interested in product management roles.",
        createdAt: new Date(Date.now() - 3600000 * 5)
      },
      {
        senderId: alumniNeha._id,
        receiverId: studentPriya._id,
        message: "Hi Priya, that's great! Let's schedule a session next week.",
        createdAt: new Date(Date.now() - 3600000 * 4.8)
      }
    ]);

    console.log('Messages seeded...');

    console.log('Data Import Success!');
    process.exit();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
};

importData();
