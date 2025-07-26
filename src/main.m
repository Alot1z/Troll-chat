#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "llama.h"  // Ensure llama.cpp headers are present and built

int main(int argc, char * argv[]) {
    @autoreleasepool {
        printf("TrollChat CLI – Offline LLM assistant\n");

        const char *model_path = "./models/tinyllama.gguf";
        if (access(model_path, F_OK) != 0) {
            fprintf(stderr, "❌ Model file not found at: %s\n", model_path);
            return 1;
        }

        struct llama_model_params mparams = llama_model_default_params();
        struct llama_model *model = llama_load_model_from_file(model_path, mparams);
        if (!model) {
            fprintf(stderr, "❌ Failed to load model: %s\n", model_path);
            return 1;
        }

        struct llama_context_params cparams = llama_context_default_params();
        struct llama_context *ctx = llama_new_context_with_model(model, cparams);
        if (!ctx) {
            fprintf(stderr, "❌ Failed to create context\n");
            llama_free_model(model);
            return 1;
        }

        const char *prompt = "You are a helpful assistant.\nUser: Hello\nAssistant:";
        llama_token tokens[1024];
        int n = llama_tokenize(ctx, prompt, tokens, 1024, true);
        if (n <= 0) {
            fprintf(stderr, "❌ Tokenization failed\n");
            llama_free(ctx);
            llama_free_model(model);
            return 1;
        }

        if (llama_eval(ctx, tokens, n, 0, 1) != 0) {
            fprintf(stderr, "❌ Evaluation failed\n");
            llama_free(ctx);
            llama_free_model(model);
            return 1;
        }

        printf("🧠 Response:\n");

        for (int i = 0; i < 128; ++i) {
            llama_token tok = llama_sample_token(ctx);
            const char *s = llama_token_to_str(ctx, tok);
            if (!s) {
                fprintf(stderr, "\n⚠️ Token to string failed\n");
                break;
            }
            printf("%s", s);
            fflush(stdout);
            if (llama_eval(ctx, &tok, 1, n + i, 1) != 0) {
                fprintf(stderr, "\n⚠️ Evaluation failed mid-generation\n");
                break;
            }
        }

        printf("\n✅ Finished\n");

        llama_free(ctx);
        llama_free_model(model);
        return 0;
    }
}
