/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";

import * as functions from "firebase-functions/v2";
import { HttpsError, CallableRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Inicialize o SDK Admin
admin.initializeApp();

// Função HTTP Callable para adicionar um custom claim de 'admin'
// Em 2ª Geração, a função onCall recebe apenas um 'request'
export const addAdminRole = functions.https.onCall(
    async (request: CallableRequest<any>) => { // Usamos 'any' para 'data' para validação posterior

        // 1. Verifique se o chamador da função está autenticado
        // O 'auth' agora está diretamente dentro do objeto 'request'
        if (!request.auth) {
            throw new HttpsError( // Use HttpsError da 2ª Geração
                "unauthenticated",
                "Apenas usuários autenticados podem adicionar roles."
            );
        }

        // 2. Verifique se o chamador já é um administrador (para segurança)
        // O 'uid' também está dentro de 'request.auth'
        const callerUid = request.auth.uid;
        const callerUserRecord = await admin.auth().getUser(callerUid);

        // Se o chamador não tem customClaims ou se customClaims.admin não é true
        if (!callerUserRecord.customClaims || callerUserRecord.customClaims.admin !== true) {
            throw new HttpsError(
                "permission-denied",
                "Apenas administradores podem adicionar ou modificar roles."
            );
        }

        // 3. Validação do UID do usuário que receberá o role
        // O 'data' agora está dentro do objeto 'request'
        const uid = (request.data as any).uid; // O tipo 'any' ainda é usado para acessar 'uid'
        if (typeof uid !== 'string' || uid.trim() === '') {
            throw new HttpsError(
                "invalid-argument",
                "O UID do usuário é obrigatório e deve ser uma string válida."
            );
        }

        try {
            // 4. Defina o custom claim 'admin: true' para o usuário
            await admin.auth().setCustomUserClaims(uid, { admin: true });

            // 5. Opcional: force a atualização do token do usuário para que as novas claims sejam propagadas
            await admin.auth().revokeRefreshTokens(uid);

            return { message: `Usuário ${uid} agora é administrador.` };
        } catch (error: any) {
            console.error("Erro ao adicionar role de admin:", error);
            throw new HttpsError(
                "internal",
                "Falha ao adicionar role de admin.",
                (error as Error).message
            );
        }
    }
);