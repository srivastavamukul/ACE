import mongoose from "mongoose";

export const portalSchema = new mongoose.Schema({
    UID: { type: String, required: true},
    portals: [
        {
            querySubject: {
                type: String,
                // required: true,
            },
            querierId: {
                type: String,
                required: true,
            },
            dateInitialized: {
                type: Date,
                required: true
            },
            dateQueryClosed: {
                type: Date,
            },
            queryStatus: {
                type: String,
                enum: ['pending', 'ongoing', 'solved'],
                required: true,
                default: 'pending'
            },
            messages: [
                {
                    type: String
                }
            ]
        }

    ],
  
});

export const Portal = mongoose.model("Portal", portalSchema);