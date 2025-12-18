import jsPDF from 'jspdf';
import QRCode from 'qrcode';

interface CertificateData {
    studentName: string;
    courseTitle: string;
    completionDate: string;
    completionRate: number;
}

export const generateCertificatePDF = async (data: CertificateData): Promise<void> => {
    const doc = new jsPDF({
        orientation: 'landscape',
        unit: 'mm',
        format: [297, 210] // A4 landscape
    });

    // Coursera-style color scheme - Clean and minimal
    const primaryColor = [20, 20, 20]; // Almost black
    const secondaryColor = [100, 100, 100]; // Medium gray
    const lightGray = [150, 150, 150]; // Light gray
    const accentColor = [0, 122, 255]; // Blue accent (Coursera blue)
    const white = [255, 255, 255];

    // Clean white background
    doc.setFillColor(...white);
    doc.rect(0, 0, 297, 210, 'F');

    // Top border - subtle and elegant (Coursera style)
    doc.setFillColor(...accentColor);
    doc.rect(0, 0, 297, 8, 'F');

    // Bottom border
    doc.rect(0, 202, 297, 8, 'F');

    // Left and right subtle borders
    doc.setDrawColor(230, 230, 230);
    doc.setLineWidth(0.5);
    doc.line(15, 0, 15, 210);
    doc.line(282, 0, 282, 210);

    // Logo area (top left) - Smart Academy branding
    doc.setFontSize(16);
    doc.setTextColor(...accentColor);
    doc.setFont('helvetica', 'bold');
    doc.text('Smart Academy', 20, 25);

    // Certificate text - Large and bold (Coursera style)
    doc.setFontSize(48);
    doc.setTextColor(...primaryColor);
    doc.setFont('helvetica', 'bold');
    doc.text('Certificate', 148.5, 50, { align: 'center' });

    // Subtitle - Clean and minimal
    doc.setFontSize(14);
    doc.setTextColor(...secondaryColor);
    doc.setFont('helvetica', 'normal');
    doc.text('This is to certify that', 148.5, 65, { align: 'center' });

    // Student Name - Very prominent (Coursera style)
    doc.setFontSize(36);
    doc.setTextColor(...primaryColor);
    doc.setFont('helvetica', 'bold');
    const studentNameY = 88;
    doc.text(data.studentName, 148.5, studentNameY, { align: 'center' });

    // Completion text - Clean and simple
    doc.setFontSize(14);
    doc.setTextColor(...secondaryColor);
    doc.setFont('helvetica', 'normal');
    doc.text('has successfully completed', 148.5, 105, { align: 'center' });

    // Course Title - Prominent but elegant
    doc.setFontSize(22);
    doc.setTextColor(...accentColor);
    doc.setFont('helvetica', 'bold');
    const courseTitleY = 125;
    doc.text(data.courseTitle, 148.5, courseTitleY, { align: 'center' });

    // Date and completion info - Minimalist style
    const infoY = 150;
    doc.setFontSize(12);
    doc.setTextColor(...secondaryColor);
    doc.setFont('helvetica', 'normal');
    doc.text(`Completed on ${data.completionDate}`, 148.5, infoY, { align: 'center' });
    
    doc.setFontSize(11);
    doc.setTextColor(...lightGray);
    doc.text(`Completion Rate: ${data.completionRate}%`, 148.5, infoY + 8, { align: 'center' });

    // Generate verification code
    const verificationCode = `SA-${Date.now().toString(36).toUpperCase().substring(0, 8)}`;
    const verificationUrl = `https://smart-academy.org/verify/${verificationCode}`;

    // Generate QR Code - Coursera style (bottom right)
    try {
        const qrCodeDataUrl = await QRCode.toDataURL(verificationUrl, {
            width: 400,
            margin: 3,
            color: {
                dark: '#000000',
                light: '#FFFFFF'
            },
            errorCorrectionLevel: 'M'
        });

        // Add QR Code to PDF (bottom right corner)
        const qrSize = 30; // mm
        const qrX = 297 - qrSize - 20;
        const qrY = 210 - qrSize - 25;
        doc.addImage(qrCodeDataUrl, 'PNG', qrX, qrY, qrSize, qrSize);

        // QR Code label - Minimalist
        doc.setFontSize(9);
        doc.setTextColor(...lightGray);
        doc.setFont('helvetica', 'normal');
        doc.text('Verify at smart-academy.org', qrX + qrSize / 2, qrY + qrSize + 4, { align: 'center' });
    } catch (error) {
        console.error('Error generating QR code:', error);
    }

    // Verification code - Bottom left (Coursera style)
    doc.setFontSize(9);
    doc.setTextColor(...lightGray);
    doc.setFont('helvetica', 'normal');
    doc.text(`Certificate ID: ${verificationCode}`, 20, 195);

    // Footer - Clean and minimal
    doc.setFontSize(10);
    doc.setTextColor(...secondaryColor);
    doc.setFont('helvetica', 'normal');
    doc.text('This certificate verifies that the above individual has completed the course.', 148.5, 175, { align: 'center' });
    
    // Signature area - Bottom center (Coursera style)
    const signatureY = 160;
    doc.setDrawColor(200, 200, 200);
    doc.setLineWidth(0.5);
    
    // Signature line
    doc.line(100, signatureY, 197, signatureY);
    
    doc.setFontSize(9);
    doc.setTextColor(...lightGray);
    doc.setFont('helvetica', 'normal');
    doc.text('Course Instructor', 148.5, signatureY + 6, { align: 'center' });

    // Decorative element - Minimalist line separator
    doc.setDrawColor(220, 220, 220);
    doc.setLineWidth(1);
    doc.line(50, 75, 247, 75);
    doc.line(50, 140, 247, 140);

    // Save the PDF
    const fileName = `Certificate_${data.courseTitle.replace(/\s+/g, '_')}_${data.studentName.replace(/\s+/g, '_')}.pdf`;
    doc.save(fileName);
};

