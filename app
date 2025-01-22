// Distribution of weights for grade computation
const gradeWeights = {
  assignments: 0.3,
  exams: 0.5,
  attendance: 0.2,
};

/**
 * Ensures a student score is a number between 0 and 100.
 * @param {number} score - Student's score for a specific metric.
 * @param {string} metric - The metric being validated.
 * @throws Throws an error if validation fails.
 */
function validateScore(score, metric) {
  if (typeof score !== "number" || score < 0 || score > 100) {
    throw new Error(
      `The ${metric} score of ${score} is invalid. It must be between 0 and 100.`
    );
  }
}

/**
 * Computes the final grade for a student based on performance and set weights.
 * @param {Object} subject - Student object containing their performance metrics.
 * @returns {number} - Final grade.
 * @throws Throws an error if validation fails.
 */
function calculateFinalGrade(subject) {
  // Check student data validity
  if (
    !subject ||
    typeof subject !== "object" ||
    !subject.performance ||
    typeof subject.performance != "object"
  ) {
    throw new Error("Student data is improperly structured.");
  }

  // Extract student metrics from performance
  const { assignments, exams, attendance } = subject.performance;

  validateScore(assignments, "assignments");
  validateScore(exams, "exams");
  validateScore(attendance, "attendance");

  // Compute final grade
  const finalGrade =
    assignments * gradeWeights.assignments +
    exams * gradeWeights.exams +
    attendance * gradeWeights.attendance;

  return finalGrade;
}

/**
 * Creates a transcript for each student.
 * @param {Array} students - An array of student objects.
 * @returns {Array} - An array of transcript objects.
 */
function generateTranscript(students) {
  const transcripts = [];

  // Ensure students is an array
  if (!Array.isArray(students)) {
    console.error("Error: The provided students data is not an array.");
    return transcripts;
  }

  students.forEach((student) => {
    try {
      // Extract student properties
      const { id, name, semesters } = student;

      // Validate student structure
      if (!id || !name || !Array.isArray(semesters)) {
        throw new Error(
          `Student structure is incomplete for ID: ${id || "Unknown"}.`
        );
      }

      const transcript = {
        studentId: id,
        name: name,
        semesters: [],
        cumulativeGPA: 0,
        academicHonors: "None",
      };

      let cumulativeGPA = 0;
      let totalCredits = 0;

      semesters.forEach((semester) => {
        const { term, subjects } = semester;

        // Validate semester structure
        if (!term || !Array.isArray(subjects)) {
          throw new Error(`Semester data is missing or invalid for ID: ${id}.`);
        }

        let semesterGPA = 0;
        let semesterCredits = 0;
        const semesterData = {
          term: term,
          subjects: [],
          semesterGPA: 0,
        };

        subjects.forEach((subject) => {
          const { name: subjectName, credits, performance } = subject;

          // Validate subject structure
          if (
            !subjectName ||
            typeof credits !== "number" ||
            credits <= 0 ||
            !performance
          ) {
            throw new Error(
              `Subject details are incorrect in ${term} for student ID: ${id}.`
            );
          }

          // Compute final grade
          const finalGrade = calculateFinalGrade(subject);

          // Determine grade point
          const gradePoint = (finalGrade / 100) * 4;

          semesterGPA += gradePoint * credits;
          semesterCredits += credits;
          totalCredits += credits;

          semesterData.subjects.push({
            name: subjectName,
            credits: credits,
            finalGrade: finalGrade.toFixed(2),
            GPA: gradePoint.toFixed(2),
          });
        });

        // Prevent division by zero
        if (semesterCredits === 0) {
          throw new Error(
            `No credits recorded for ${term} in student ID: ${id}.`
          );
        }

        semesterGPA /= semesterCredits;
        cumulativeGPA += semesterGPA * semesterCredits;

        semesterData.semesterGPA = semesterGPA.toFixed(2);
        transcript.semesters.push(semesterData);
      });

      // Prevent division by zero
      if (totalCredits === 0) {
        throw new Error(`No credits accumulated for student ID: ${id}.`);
      }

      cumulativeGPA /= totalCredits;
      transcript.cumulativeGPA = cumulativeGPA.toFixed(2);

      // Determine academic honors
      if (cumulativeGPA >= 3.7) {
        transcript.academicHonors = "High Honors";
      } else if (cumulativeGPA >= 3.3) {
        transcript.academicHonors = "Honors";
      } else {
        transcript.academicHonors = "None";
      }

      transcripts.push(transcript);
    } catch (error) {
      console.error(`Processing error for student: ${error.message}\n`);
    }
  });

  return transcripts;
}

/**
 * Outputs the transcript data to the console.
 * @param {Array} transcripts - An array of transcript objects.
 */
function logTranscript(transcripts) {
  transcripts.forEach((transcript) => {
    console.log(`Student ID: ${transcript.studentId}, Name: ${transcript.name}`);
    let cumulativeGPA = transcript.cumulativeGPA;

    transcript.semesters.forEach((semester) => {
      console.log(`Semester: ${semester.term}`);
      semester.subjects.forEach((subject) => {
        console.log(
          `Subject: ${subject.name}, Credits: ${subject.credits}, Final Grade: ${subject.finalGrade}%, GPA: ${subject.GPA}`
        );
      });
      console.log(`Semester GPA: ${semester.semesterGPA}`);
    });

    console.log(`Cumulative GPA: ${cumulativeGPA}`);
    console.log(`Academic Honors: ${transcript.academicHonors}`);

    console.log(); // Add a blank line for clarity
  });
}

//Example JSON object with students' academic records
const studentsData = {
  students: [
    {
      id: "S001",
      name: "Alice",
      semesters: [
        {
          term: "Fall 2023",
          subjects: [
            {
              name: "Math",
              credits: 4,
              performance: { assignments: 80, exams: 70, attendance: 85 },
            },
            {
              name: "Physics",
              credits: 3,
              performance: { assignments: 90, exams: 60, attendance: 70 },
            },
          ],
        },
      ],
    },
    {
      id: "S002",
      name: "Bob",
      semesters: [
        {
          term: "Fall 2023",
          subjects: [
            {
              name: "Math",
              credits: 4,
              performance: { assignments: 85, exams: 75, attendance: 90 },
            },
            {
              name: "English",
              credits: 2,
              performance: { assignments: 95, exams: 82, attendance: 60 },
            },
          ],
        },
      ],
    },
  ],
};

//Create transcripts for all students
const transcripts = generateTranscript(studentsData.students);

// Display the transcripts
logTranscript(transcripts);
