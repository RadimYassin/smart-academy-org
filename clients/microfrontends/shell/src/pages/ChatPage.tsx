import React, { useState, useRef, useEffect } from 'react';
import { Send, Sparkles, Loader, Bot, User, Image as ImageIcon, Mic, X, Play, Pause, Square, Circle } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import rehypeHighlight from 'rehype-highlight';
import { edubotApi } from '../api/edubotApi';
import type { AnswerResponse, ImageAnalysisResponse, AudioProcessingResponse } from '../api/edubotApi';
import { handleApiError } from '../api/apiClient';

interface Message {
    id: string;
    role: 'user' | 'assistant';
    content: string;
    sources?: AnswerResponse['sources'];
    timestamp: Date;
    imageUrl?: string;
    audioUrl?: string;
    transcription?: string;
}

const ChatPage: React.FC = () => {
    console.log('[ChatPage] Component rendered');
    
    const [messages, setMessages] = useState<Message[]>([
        {
            id: '1',
            role: 'assistant',
            content: 'Bonjour ! Je suis votre assistant pédagogique intelligent EduBot. Je peux répondre à vos questions sur les cours en utilisant une approche socratique. Posez-moi une question !',
            timestamp: new Date(),
        },
    ]);
    const [input, setInput] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [typingMessageId, setTypingMessageId] = useState<string | null>(null);
    const [displayedContent, setDisplayedContent] = useState<Record<string, string>>({});
    const [selectedImage, setSelectedImage] = useState<File | null>(null);
    const [selectedAudio, setSelectedAudio] = useState<File | null>(null);
    const [playingAudioId, setPlayingAudioId] = useState<string | null>(null);
    const [isRecording, setIsRecording] = useState(false);
    const [recordingTime, setRecordingTime] = useState(0);
    const messagesEndRef = useRef<HTMLDivElement>(null);
    const inputRef = useRef<HTMLTextAreaElement>(null);
    const imageInputRef = useRef<HTMLInputElement>(null);
    const audioInputRef = useRef<HTMLInputElement>(null);
    const audioRefs = useRef<Record<string, HTMLAudioElement>>({});
    const mediaRecorderRef = useRef<MediaRecorder | null>(null);
    const audioChunksRef = useRef<Blob[]>([]);
    const recordingTimerRef = useRef<NodeJS.Timeout | null>(null);
    const typingIntervalRef = useRef<NodeJS.Timeout | null>(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages, displayedContent]);

    // Cleanup typing interval on unmount
    useEffect(() => {
        return () => {
            if (typingIntervalRef.current) {
                clearInterval(typingIntervalRef.current);
            }
        };
    }, []);

    const handleSend = async () => {
        // Check if we have image or audio to process
        if (selectedImage) {
            await handleImageSend();
            return;
        }
        if (selectedAudio) {
            await handleAudioSend();
            return;
        }
        
        if (!input.trim() || isLoading) return;

        const userMessage: Message = {
            id: Date.now().toString(),
            role: 'user',
            content: input.trim(),
            timestamp: new Date(),
        };

        setMessages((prev) => [...prev, userMessage]);
        setInput('');
        setIsLoading(true);
        setError(null);

        try {
            const response = await edubotApi.askQuestion(input.trim());
            
            const assistantMessageId = (Date.now() + 1).toString();
            const assistantMessage: Message = {
                id: assistantMessageId,
                role: 'assistant',
                content: response.answer,
                sources: response.sources,
                timestamp: new Date(),
            };

            // Add message with full content first
            setMessages((prev) => [...prev, assistantMessage]);
            
            // Start typing effect
            setTypingMessageId(assistantMessageId);
            setDisplayedContent(prev => ({ ...prev, [assistantMessageId]: '' }));
            
            // Clear any existing interval
            if (typingIntervalRef.current) {
                clearInterval(typingIntervalRef.current);
            }
            
            // Type out the answer character by character with smooth animation
            const fullAnswer = response.answer;
            let currentIndex = 0;
            
            // Start typing animation after a small delay for better UX
            setTimeout(() => {
                typingIntervalRef.current = setInterval(() => {
                    if (currentIndex < fullAnswer.length) {
                        // Variable speed: faster for spaces and punctuation
                        const char = fullAnswer[currentIndex];
                        const increment = (char === ' ' || char === '\n' || char === '.' || char === ',' || char === '!') ? 1 : 1;
                        currentIndex += increment;
                        
                        const partialContent = fullAnswer.substring(0, currentIndex);
                        setDisplayedContent(prev => ({ ...prev, [assistantMessageId]: partialContent }));
                    } else {
                        // Typing complete
                        if (typingIntervalRef.current) {
                            clearInterval(typingIntervalRef.current);
                            typingIntervalRef.current = null;
                        }
                        setTypingMessageId(null);
                        setDisplayedContent(prev => ({ ...prev, [assistantMessageId]: fullAnswer }));
                    }
                }, 15); // 15ms interval for smooth, fast typing animation
            }, 150); // Small delay before starting to type
            
        } catch (err) {
            const errorMessage = handleApiError(err);
            setError(errorMessage);
            
            const errorMsg: Message = {
                id: (Date.now() + 1).toString(),
                role: 'assistant',
                content: `Désolé, une erreur s'est produite : ${errorMessage}. Veuillez réessayer.`,
                timestamp: new Date(),
            };
            setMessages((prev) => [...prev, errorMsg]);
        } finally {
            setIsLoading(false);
        }
    };

    const handleKeyPress = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleSend();
        }
    };

    const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            if (file.size > 10 * 1024 * 1024) {
                setError('Image size must be less than 10MB');
                return;
            }
            setSelectedImage(file);
            setSelectedAudio(null);
            setTimeout(() => inputRef.current?.focus(), 100);
        }
    };

    const handleAudioSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            if (file.size > 25 * 1024 * 1024) {
                setError('Audio size must be less than 25MB');
                return;
            }
            setSelectedAudio(file);
            setSelectedImage(null);
        }
    };

    const startRecording = async () => {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ 
                audio: {
                    channelCount: 1,
                    sampleRate: 16000,
                    echoCancellation: true,
                    noiseSuppression: true,
                }
            });
            
            // Try to use a format that's more compatible
            let mimeType = 'audio/webm';
            if (MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
                mimeType = 'audio/webm;codecs=opus';
            } else if (MediaRecorder.isTypeSupported('audio/ogg;codecs=opus')) {
                mimeType = 'audio/ogg;codecs=opus';
            }
            
            const mediaRecorder = new MediaRecorder(stream, { mimeType });
            mediaRecorderRef.current = mediaRecorder;
            audioChunksRef.current = [];

            mediaRecorder.ondataavailable = (event) => {
                if (event.data.size > 0) {
                    audioChunksRef.current.push(event.data);
                }
            };

            mediaRecorder.onstop = async () => {
                const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
                
                // Convert WebM to WAV format
                try {
                    const wavBlob = await convertWebMToWAV(audioBlob);
                    const audioFile = new File([wavBlob], `recording-${Date.now()}.wav`, { type: 'audio/wav' });
                    setSelectedAudio(audioFile);
                    setSelectedImage(null);
                } catch (err) {
                    console.error('Error converting audio:', err);
                    setError('Erreur lors de la conversion audio. Veuillez réessayer.');
                }
                
                // Stop all tracks
                stream.getTracks().forEach(track => track.stop());
            };

            mediaRecorder.start();
            setIsRecording(true);
            setRecordingTime(0);

            // Start timer
            recordingTimerRef.current = setInterval(() => {
                setRecordingTime(prev => prev + 1);
            }, 1000);

        } catch (err) {
            console.error('Error starting recording:', err);
            setError('Impossible d\'accéder au microphone. Veuillez vérifier les permissions.');
        }
    };

    const stopRecording = () => {
        if (mediaRecorderRef.current && isRecording) {
            mediaRecorderRef.current.stop();
            setIsRecording(false);
            if (recordingTimerRef.current) {
                clearInterval(recordingTimerRef.current);
                recordingTimerRef.current = null;
            }
        }
    };

    // Convert WebM blob to WAV format for API compatibility
    const convertWebMToWAV = async (webmBlob: Blob): Promise<Blob> => {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = async () => {
                try {
                    const arrayBuffer = reader.result as ArrayBuffer;
                    
                    // Create AudioContext
                    const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
                    
                    // Decode audio data
                    const audioBuffer = await audioContext.decodeAudioData(arrayBuffer.slice(0));
                    
                    // Convert to WAV
                    const wav = audioBufferToWAV(audioBuffer);
                    const wavBlob = new Blob([wav], { type: 'audio/wav' });
                    resolve(wavBlob);
                } catch (err) {
                    console.error('Error converting audio:', err);
                    reject(err);
                }
            };
            reader.onerror = reject;
            reader.readAsArrayBuffer(webmBlob);
        });
    };

    // Convert AudioBuffer to WAV format
    const audioBufferToWAV = (buffer: AudioBuffer): ArrayBuffer => {
        const length = buffer.length;
        const numberOfChannels = buffer.numberOfChannels;
        const sampleRate = buffer.sampleRate;
        const bytesPerSample = 2;
        const blockAlign = numberOfChannels * bytesPerSample;
        const byteRate = sampleRate * blockAlign;
        const dataSize = length * blockAlign;
        const bufferSize = 44 + dataSize;
        const arrayBuffer = new ArrayBuffer(bufferSize);
        const view = new DataView(arrayBuffer);

        // Write WAV header
        const writeString = (offset: number, string: string) => {
            for (let i = 0; i < string.length; i++) {
                view.setUint8(offset + i, string.charCodeAt(i));
            }
        };

        writeString(0, 'RIFF');
        view.setUint32(4, bufferSize - 8, true);
        writeString(8, 'WAVE');
        writeString(12, 'fmt ');
        view.setUint32(16, 16, true); // fmt chunk size
        view.setUint16(20, 1, true); // audio format (1 = PCM)
        view.setUint16(22, numberOfChannels, true);
        view.setUint32(24, sampleRate, true);
        view.setUint32(28, byteRate, true);
        view.setUint16(32, blockAlign, true);
        view.setUint16(34, 16, true); // bits per sample
        writeString(36, 'data');
        view.setUint32(40, dataSize, true);

        // Convert float samples to 16-bit PCM
        let offset = 44;
        for (let i = 0; i < length; i++) {
            for (let channel = 0; channel < numberOfChannels; channel++) {
                const sample = Math.max(-1, Math.min(1, buffer.getChannelData(channel)[i]));
                view.setInt16(offset, sample < 0 ? sample * 0x8000 : sample * 0x7FFF, true);
                offset += 2;
            }
        }

        return arrayBuffer;
    };

    const formatRecordingTime = (seconds: number): string => {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    };

    const handleImageSend = async () => {
        if (!selectedImage || isLoading) return;

        const question = input.trim() || 'Analyze this image';
        
        const imageUrl = URL.createObjectURL(selectedImage);
        const userMessage: Message = {
            id: Date.now().toString(),
            role: 'user',
            content: question,
            imageUrl: imageUrl,
            timestamp: new Date(),
        };

        setMessages((prev) => [...prev, userMessage]);
        setInput('');
        setSelectedImage(null);
        setIsLoading(true);
        setError(null);

        try {
            const response = await edubotApi.analyzeImage(selectedImage, question);
            
            const assistantMessageId = (Date.now() + 1).toString();
            const assistantMessage: Message = {
                id: assistantMessageId,
                role: 'assistant',
                content: response.analysis,
                timestamp: new Date(),
            };

            setMessages((prev) => [...prev, assistantMessage]);
            
            setTypingMessageId(assistantMessageId);
            setDisplayedContent(prev => ({ ...prev, [assistantMessageId]: '' }));
            
            if (typingIntervalRef.current) {
                clearInterval(typingIntervalRef.current);
            }
            
            const fullAnswer = response.analysis;
            let currentIndex = 0;
            
            setTimeout(() => {
                typingIntervalRef.current = setInterval(() => {
                    if (currentIndex < fullAnswer.length) {
                        const char = fullAnswer[currentIndex];
                        const increment = (char === ' ' || char === '\n' || char === '.' || char === ',' || char === '!') ? 1 : 1;
                        currentIndex += increment;
                        
                        const partialContent = fullAnswer.substring(0, currentIndex);
                        setDisplayedContent(prev => ({ ...prev, [assistantMessageId]: partialContent }));
                    } else {
                        if (typingIntervalRef.current) {
                            clearInterval(typingIntervalRef.current);
                            typingIntervalRef.current = null;
                        }
                        setTypingMessageId(null);
                        setDisplayedContent(prev => ({ ...prev, [assistantMessageId]: fullAnswer }));
                    }
                }, 15);
            }, 150);
            
        } catch (err) {
            const errorMessage = handleApiError(err);
            setError(errorMessage);
            
            const errorMsg: Message = {
                id: (Date.now() + 1).toString(),
                role: 'assistant',
                content: `Désolé, une erreur s'est produite lors de l'analyse de l'image : ${errorMessage}. Veuillez réessayer.`,
                timestamp: new Date(),
            };
            setMessages((prev) => [...prev, errorMsg]);
        } finally {
            setIsLoading(false);
        }
    };

    const handleAudioSend = async () => {
        if (!selectedAudio || isLoading) return;

        const question = input.trim();
        
        const audioUrl = URL.createObjectURL(selectedAudio);
        const userMessage: Message = {
            id: Date.now().toString(),
            role: 'user',
            content: question || '🎤 Audio message',
            audioUrl: audioUrl,
            timestamp: new Date(),
        };

        setMessages((prev) => [...prev, userMessage]);
        setInput('');
        setSelectedAudio(null);
        setIsLoading(true);
        setError(null);

        try {
            const response = await edubotApi.processAudio(selectedAudio, question || undefined);
            
            const assistantMessageId = (Date.now() + 1).toString();
            const assistantMessage: Message = {
                id: assistantMessageId,
                role: 'assistant',
                content: response.answer,
                transcription: response.transcription,
                audioUrl: response.audio_url,
                sources: response.sources,
                timestamp: new Date(),
            };

            setMessages((prev) => [...prev, assistantMessage]);
            
            setTypingMessageId(assistantMessageId);
            setDisplayedContent(prev => ({ ...prev, [assistantMessageId]: '' }));
            
            if (typingIntervalRef.current) {
                clearInterval(typingIntervalRef.current);
            }
            
            const fullAnswer = response.answer;
            let currentIndex = 0;
            
            setTimeout(() => {
                typingIntervalRef.current = setInterval(() => {
                    if (currentIndex < fullAnswer.length) {
                        const char = fullAnswer[currentIndex];
                        const increment = (char === ' ' || char === '\n' || char === '.' || char === ',' || char === '!') ? 1 : 1;
                        currentIndex += increment;
                        
                        const partialContent = fullAnswer.substring(0, currentIndex);
                        setDisplayedContent(prev => ({ ...prev, [assistantMessageId]: partialContent }));
                    } else {
                        if (typingIntervalRef.current) {
                            clearInterval(typingIntervalRef.current);
                            typingIntervalRef.current = null;
                        }
                        setTypingMessageId(null);
                        setDisplayedContent(prev => ({ ...prev, [assistantMessageId]: fullAnswer }));
                    }
                }, 15);
            }, 150);
            
        } catch (err) {
            const errorMessage = handleApiError(err);
            setError(errorMessage);
            
            const errorMsg: Message = {
                id: (Date.now() + 1).toString(),
                role: 'assistant',
                content: `Désolé, une erreur s'est produite lors du traitement audio : ${errorMessage}. Veuillez réessayer.`,
                timestamp: new Date(),
            };
            setMessages((prev) => [...prev, errorMsg]);
        } finally {
            setIsLoading(false);
        }
    };

    const handlePlayAudio = (messageId: string, audioUrl: string) => {
        if (playingAudioId === messageId) {
            const audio = audioRefs.current[messageId];
            if (audio) {
                audio.pause();
                audio.currentTime = 0;
            }
            setPlayingAudioId(null);
        } else {
            Object.values(audioRefs.current).forEach(audio => {
                audio.pause();
                audio.currentTime = 0;
            });
            
            const audio = new Audio(audioUrl);
            audioRefs.current[messageId] = audio;
            setPlayingAudioId(messageId);
            
            audio.onended = () => {
                setPlayingAudioId(null);
            };
            
            audio.onerror = () => {
                setError('Erreur lors de la lecture audio');
                setPlayingAudioId(null);
            };
            
            audio.play();
        }
    };

    return (
        <>
            <style>{`
                @keyframes blink {
                    0%, 50% { opacity: 1; }
                    51%, 100% { opacity: 0; }
                }
                .typing-cursor {
                    animation: blink 1s infinite;
                }
            `}</style>
            <div className="h-full w-full flex flex-col bg-gradient-to-br from-gray-50 via-white to-purple-50/30 dark:from-gray-900 dark:via-gray-800 dark:to-purple-900/10 absolute inset-0">
            {/* Header */}
            <div className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-6 py-4 shadow-sm">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500 to-indigo-600 flex items-center justify-center">
                        <Sparkles className="text-white" size={20} />
                    </div>
                    <div>
                        <h1 className="text-xl font-bold text-gray-900 dark:text-white">
                            EduBot Assistant
                        </h1>
                        <p className="text-sm text-gray-500 dark:text-gray-400">
                            Assistant pédagogique intelligent basé sur RAG
                        </p>
                    </div>
                </div>
            </div>

            {/* Messages Container */}
            <div className="flex-1 overflow-y-auto px-4 sm:px-6 py-6">
                <div className="max-w-4xl mx-auto space-y-6">
                    <AnimatePresence>
                        {messages.map((message) => (
                            <motion.div
                                key={message.id}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0 }}
                                className={`flex gap-4 ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
                            >
                                {message.role === 'assistant' && (
                                    <div className="w-8 h-8 rounded-full bg-gradient-to-br from-purple-500 to-indigo-600 flex items-center justify-center flex-shrink-0">
                                        <Bot className="text-white" size={18} />
                                    </div>
                                )}
                                
                                <div className={`flex flex-col gap-2 max-w-[80%] sm:max-w-[70%] ${message.role === 'user' ? 'items-end' : 'items-start'}`}>
                                    <div
                                        className={`rounded-2xl px-4 py-3 ${
                                            message.role === 'user'
                                                ? 'bg-gradient-to-br from-purple-500 to-indigo-600 text-white'
                                                : 'bg-white dark:bg-gray-800 text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700 shadow-sm'
                                        }`}
                                    >
                                        {message.role === 'user' ? (
                                            <div className="space-y-2">
                                                {message.imageUrl && (
                                                    <div className="rounded-lg overflow-hidden max-w-md">
                                                        <img 
                                                            src={message.imageUrl} 
                                                            alt="Uploaded" 
                                                            className="w-full h-auto"
                                                        />
                                                    </div>
                                                )}
                                                {message.audioUrl && (
                                                    <div className="flex items-center gap-2 bg-white/10 rounded-lg p-2">
                                                        <button
                                                            onClick={() => handlePlayAudio(message.id, message.audioUrl!)}
                                                            className="p-2 rounded-full bg-white/20 hover:bg-white/30 transition-colors"
                                                        >
                                                            {playingAudioId === message.id ? (
                                                                <Pause className="text-white" size={16} />
                                                            ) : (
                                                                <Play className="text-white" size={16} />
                                                            )}
                                                        </button>
                                                        <span className="text-sm text-white/90">Audio message</span>
                                                    </div>
                                                )}
                                                <p className="text-sm sm:text-base leading-relaxed whitespace-pre-wrap">
                                                    {message.content}
                                                </p>
                                            </div>
                                        ) : (
                                            <div className="text-sm sm:text-base leading-relaxed prose prose-sm dark:prose-invert max-w-none 
                                                prose-headings:font-bold prose-headings:text-gray-900 dark:prose-headings:text-white prose-headings:mt-4 prose-headings:mb-2 
                                                prose-p:text-gray-700 dark:prose-p:text-gray-300 prose-p:my-2 prose-p:leading-relaxed
                                                prose-strong:text-gray-900 dark:prose-strong:text-white prose-strong:font-semibold
                                                prose-ul:my-2 prose-ul:list-disc prose-ul:pl-6
                                                prose-ol:my-2 prose-ol:list-decimal prose-ol:pl-6
                                                prose-li:my-1 prose-li:text-gray-700 dark:prose-li:text-gray-300
                                                prose-code:text-purple-600 dark:prose-code:text-purple-400 prose-code:bg-purple-50 dark:prose-code:bg-purple-900/20 prose-code:px-1.5 prose-code:py-0.5 prose-code:rounded prose-code:text-sm prose-code:font-mono
                                                prose-pre:bg-gray-100 dark:prose-pre:bg-gray-900 prose-pre:border prose-pre:border-gray-200 dark:prose-pre:border-gray-700 prose-pre:rounded-lg prose-pre:p-4 prose-pre:overflow-x-auto
                                                prose-blockquote:border-l-4 prose-blockquote:border-purple-500 dark:prose-blockquote:border-purple-400 prose-blockquote:pl-4 prose-blockquote:italic prose-blockquote:text-gray-600 dark:prose-blockquote:text-gray-400">
                                                {typingMessageId === message.id ? (
                                                    <>
                                                        <ReactMarkdown
                                                            remarkPlugins={[remarkGfm]}
                                                            rehypePlugins={[rehypeHighlight]}
                                                        >
                                                            {displayedContent[message.id] || ''}
                                                        </ReactMarkdown>
                                                        <span className="inline-block w-0.5 h-4 bg-purple-600 dark:bg-purple-400 ml-1 typing-cursor align-middle"></span>
                                                    </>
                                                ) : (
                                                    <ReactMarkdown
                                                        remarkPlugins={[remarkGfm]}
                                                        rehypePlugins={[rehypeHighlight]}
                                                    >
                                                        {message.content}
                                                    </ReactMarkdown>
                                                )}
                                            </div>
                                        )}
                                        {message.transcription && (
                                            <div className="mt-2 text-xs text-gray-500 dark:text-gray-400 italic">
                                                Transcription: "{message.transcription}"
                                            </div>
                                        )}
                                        {message.audioUrl && message.role === 'assistant' && (
                                            <div className="mt-2 flex items-center gap-2">
                                                <button
                                                    onClick={() => handlePlayAudio(message.id, message.audioUrl!)}
                                                    className="flex items-center gap-2 px-3 py-1.5 bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300 rounded-lg hover:bg-purple-200 dark:hover:bg-purple-900/50 transition-colors text-sm"
                                                >
                                                    {playingAudioId === message.id ? (
                                                        <>
                                                            <Pause size={14} />
                                                            <span>Pause</span>
                                                        </>
                                                    ) : (
                                                        <>
                                                            <Play size={14} />
                                                            <span>Écouter la réponse</span>
                                                        </>
                                                    )}
                                                </button>
                                            </div>
                                        )}
                                    </div>

                                    <span className="text-xs text-gray-400 dark:text-gray-500">
                                        {message.timestamp.toLocaleTimeString('fr-FR', {
                                            hour: '2-digit',
                                            minute: '2-digit',
                                        })}
                                    </span>
                                </div>

                                {message.role === 'user' && (
                                    <div className="w-8 h-8 rounded-full bg-gradient-to-br from-gray-400 to-gray-500 flex items-center justify-center flex-shrink-0">
                                        <User className="text-white" size={18} />
                                    </div>
                                )}
                            </motion.div>
                        ))}
                    </AnimatePresence>

                    {isLoading && (
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            className="flex gap-4 justify-start"
                        >
                            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-purple-500 to-indigo-600 flex items-center justify-center">
                                <Bot className="text-white" size={18} />
                            </div>
                            <div className="bg-white dark:bg-gray-800 rounded-2xl px-4 py-3 border border-gray-200 dark:border-gray-700">
                                <div className="flex items-center gap-2">
                                    <Loader className="text-purple-600 dark:text-purple-400 animate-spin" size={16} />
                                    <span className="text-sm text-gray-600 dark:text-gray-400">
                                        EduBot réfléchit...
                                    </span>
                                </div>
                            </div>
                        </motion.div>
                    )}

                    {error && (
                        <motion.div
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3"
                        >
                            <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
                        </motion.div>
                    )}

                    <div ref={messagesEndRef} />
                </div>
            </div>

            {/* Input Area */}
            <div className="bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 px-4 sm:px-6 py-4">
                <div className="max-w-4xl mx-auto">
                    {/* Selected file preview */}
                    {(selectedImage || selectedAudio) && (
                        <div className="mb-3 flex items-center gap-2 p-2 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
                            {selectedImage && (
                                <>
                                    <ImageIcon className="text-purple-600 dark:text-purple-400" size={18} />
                                    <span className="text-sm text-gray-700 dark:text-gray-300 flex-1 truncate">
                                        {selectedImage.name}
                                    </span>
                                    <button
                                        onClick={() => {
                                            setSelectedImage(null);
                                            if (imageInputRef.current) imageInputRef.current.value = '';
                                        }}
                                        className="p-1 hover:bg-purple-100 dark:hover:bg-purple-900/30 rounded"
                                    >
                                        <X size={16} className="text-gray-500 dark:text-gray-400" />
                                    </button>
                                </>
                            )}
                            {selectedAudio && (
                                <>
                                    <Mic className="text-purple-600 dark:text-purple-400" size={18} />
                                    <span className="text-sm text-gray-700 dark:text-gray-300 flex-1 truncate">
                                        {selectedAudio.name}
                                    </span>
                                    <button
                                        onClick={() => {
                                            setSelectedAudio(null);
                                            if (audioInputRef.current) audioInputRef.current.value = '';
                                        }}
                                        className="p-1 hover:bg-purple-100 dark:hover:bg-purple-900/30 rounded"
                                    >
                                        <X size={16} className="text-gray-500 dark:text-gray-400" />
                                    </button>
                                </>
                            )}
                        </div>
                    )}
                    <div className="flex items-end gap-3">
                        {/* Image Upload Button */}
                        <input
                            ref={imageInputRef}
                            type="file"
                            accept="image/*"
                            onChange={handleImageSelect}
                            className="hidden"
                            id="image-upload"
                        />
                        <label
                            htmlFor="image-upload"
                            className="p-3 rounded-xl bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors cursor-pointer"
                            title="Upload Image"
                        >
                            <ImageIcon className="text-gray-600 dark:text-gray-400" size={20} />
                        </label>

                        {/* Audio Record Button */}
                        {!isRecording ? (
                            <motion.button
                                whileHover={{ scale: 1.05 }}
                                whileTap={{ scale: 0.95 }}
                                onClick={startRecording}
                                disabled={isLoading}
                                className="p-3 rounded-xl bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                                title="Enregistrer un message audio"
                            >
                                <Mic className="text-gray-600 dark:text-gray-400" size={20} />
                            </motion.button>
                        ) : (
                            <motion.button
                                whileHover={{ scale: 1.05 }}
                                whileTap={{ scale: 0.95 }}
                                onClick={stopRecording}
                                className="p-3 rounded-xl bg-red-500 hover:bg-red-600 text-white transition-colors flex items-center gap-2"
                                title="Arrêter l'enregistrement"
                            >
                                <div className="w-3 h-3 bg-white rounded-full animate-pulse"></div>
                                <span className="text-sm font-medium">{formatRecordingTime(recordingTime)}</span>
                                <Square size={16} />
                            </motion.button>
                        )}

                        <div className="flex-1 relative">
                            <textarea
                                ref={inputRef}
                                value={input}
                                onChange={(e) => setInput(e.target.value)}
                                onKeyPress={handleKeyPress}
                                placeholder="Posez votre question sur les cours..."
                                rows={1}
                                className="w-full px-4 py-3 pr-12 bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-500 dark:focus:ring-purple-400 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500 resize-none"
                                style={{ minHeight: '48px', maxHeight: '120px' }}
                                onInput={(e) => {
                                    const target = e.target as HTMLTextAreaElement;
                                    target.style.height = 'auto';
                                    target.style.height = `${Math.min(target.scrollHeight, 120)}px`;
                                }}
                            />
                            <div className="absolute bottom-2 right-2 text-xs text-gray-400 dark:text-gray-500">
                                {input.length}/1000
                            </div>
                        </div>
                        <motion.button
                            whileHover={{ scale: 1.05 }}
                            whileTap={{ scale: 0.95 }}
                            onClick={handleSend}
                            disabled={(!input.trim() && !selectedImage && !selectedAudio) || isLoading}
                            className={`p-3 rounded-xl transition-all ${
                                (!input.trim() && !selectedImage && !selectedAudio) || isLoading
                                    ? 'bg-gray-200 dark:bg-gray-700 text-gray-400 dark:text-gray-600 cursor-not-allowed'
                                    : 'bg-gradient-to-br from-purple-500 to-indigo-600 text-white hover:from-purple-600 hover:to-indigo-700 shadow-lg'
                            }`}
                        >
                            {isLoading ? (
                                <Loader className="animate-spin" size={20} />
                            ) : (
                                <Send size={20} />
                            )}
                        </motion.button>
                    </div>
                    <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
                        Appuyez sur Entrée pour envoyer, Maj+Entrée pour une nouvelle ligne
                    </p>
                </div>
            </div>
        </div>
        </>
    );
};

export default ChatPage;

