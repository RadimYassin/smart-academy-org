/**
 * EduBot API Client
 * 
 * Handles all interactions with the EduBot AI Assistant service
 * Based on RAG (Retrieval Augmented Generation) for educational Q&A
 * 
 * Note: EduBot uses direct connection (not through Gateway)
 */

import axios from 'axios';

// EduBot API Base URL - Direct connection (not through Gateway)
const EDUBOT_BASE_URL = 'http://172.20.10.9:8000';

// Types based on OpenAPI schema
export interface QuestionRequest {
    question: string;
}

export interface SourceDocument {
    content: string;
    source_file: string;
    page: number;
    metadata?: Record<string, unknown>;
}

export interface AnswerResponse {
    answer: string;
    model_used: string;
    num_sources: number;
    sources?: SourceDocument[];
}

export interface HealthResponse {
    status: string;
    faiss_index_exists: boolean;
    llm_provider: string;
    model: string;
}

export interface ImageAnalysisResponse {
    analysis: string;
    question: string;
    model_used: string;
}

export interface AudioProcessingResponse {
    transcription: string;
    answer: string;
    audio_url: string;
    sources?: SourceDocument[];
    model_used: string;
}

// Create a separate axios instance for EduBot (no JWT token needed)
const edubotClient = axios.create({
    baseURL: EDUBOT_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
    timeout: 60000, // 60 seconds for AI responses
});

/**
 * EduBot API functions
 */
export const edubotApi = {
    /**
     * Ask a question to the EduBot assistant
     * Uses RAG to search through indexed course documents
     * 
     * @param question - The student's question (3-1000 characters)
     * @returns AnswerResponse with answer, sources, and model info
     */
    askQuestion: async (question: string): Promise<AnswerResponse> => {
        if (!question || question.trim().length < 3) {
            throw new Error('Question must be at least 3 characters long');
        }
        if (question.length > 1000) {
            throw new Error('Question must be less than 1000 characters');
        }

        const request: QuestionRequest = { question: question.trim() };
        
        try {
            console.log('[EduBot API] Sending question to:', `${EDUBOT_BASE_URL}/chat/ask`);
            const response = await edubotClient.post<AnswerResponse>('/chat/ask', request);
            console.log('[EduBot API] Response received:', response.data);
            return response.data;
        } catch (error: any) {
            console.error('[EduBot API] Error:', error);
            if (error.response) {
                // Server responded with error status
                throw new Error(error.response.data?.detail || error.response.data?.message || `Server error: ${error.response.status}`);
            } else if (error.request) {
                // Request was made but no response received
                throw new Error('No response from EduBot service. Please check if the service is running.');
            } else {
                // Something else happened
                throw new Error(error.message || 'An unexpected error occurred');
            }
        }
    },

    /**
     * Check the health status of EduBot service
     * @returns HealthResponse with service status and configuration
     */
    checkHealth: async (): Promise<HealthResponse> => {
        try {
            const response = await edubotClient.get<HealthResponse>('/health');
            return response.data;
        } catch (error: any) {
            console.error('[EduBot API] Health check error:', error);
            throw new Error(error.response?.data?.detail || error.message || 'Health check failed');
        }
    },

    /**
     * Analyze an image and get AI analysis
     * @param imageFile - The image file to analyze
     * @param question - Question about the image
     * @returns ImageAnalysisResponse with analysis and model info
     */
    analyzeImage: async (imageFile: File, question: string): Promise<ImageAnalysisResponse> => {
        if (!imageFile) {
            throw new Error('Image file is required');
        }
        if (!question || question.trim().length < 3) {
            throw new Error('Question must be at least 3 characters long');
        }

        const formData = new FormData();
        formData.append('image', imageFile);
        formData.append('question', question.trim());

        try {
            console.log('[EduBot API] Analyzing image:', imageFile.name);
            const response = await edubotClient.post<ImageAnalysisResponse>('/chat/image', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });
            console.log('[EduBot API] Image analysis received:', response.data);
            return response.data;
        } catch (error: any) {
            console.error('[EduBot API] Image analysis error:', error);
            if (error.response) {
                throw new Error(error.response.data?.detail || error.response.data?.message || `Server error: ${error.response.status}`);
            } else if (error.request) {
                throw new Error('No response from EduBot service. Please check if the service is running.');
            } else {
                throw new Error(error.message || 'An unexpected error occurred');
            }
        }
    },

    /**
     * Process audio: transcribe, get answer, and receive audio response
     * @param audioFile - The audio file to process
     * @param question - Optional question (if provided, skips transcription)
     * @returns AudioProcessingResponse with transcription, answer, and audio URL
     */
    processAudio: async (audioFile: File, question?: string): Promise<AudioProcessingResponse> => {
        if (!audioFile) {
            throw new Error('Audio file is required');
        }

        const formData = new FormData();
        formData.append('audio', audioFile);
        if (question && question.trim().length > 0) {
            formData.append('question', question.trim());
        }

        try {
            console.log('[EduBot API] Processing audio:', audioFile.name);
            const response = await edubotClient.post<AudioProcessingResponse>('/chat/audio', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });
            console.log('[EduBot API] Audio processing received:', response.data);
            return response.data;
        } catch (error: any) {
            console.error('[EduBot API] Audio processing error:', error);
            if (error.response) {
                throw new Error(error.response.data?.detail || error.response.data?.message || `Server error: ${error.response.status}`);
            } else if (error.request) {
                throw new Error('No response from EduBot service. Please check if the service is running.');
            } else {
                throw new Error(error.message || 'An unexpected error occurred');
            }
        }
    },
};








