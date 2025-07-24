#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "llama.h"  // llama.cpp C API header

int main(int argc, char * argv[]) {
    @autoreleasepool {
        printf("TrollChat CLI – TinyLLaMA offline assistant\n");

        const char *model_path = "./models/tinyllama.gguf";

        struct llama_model_params model_params = llama_model_default_params();
        struct llama_model *model = llama_load_model_from_file(model_path, model_params);
        if (!model) {
            fprintf(stderr, "❌ Failed to load model: %s\n", model_path);
            return 1;
        }

        struct llama_context_params ctx_params = llama_context_default_params();
        struct llama_context *ctx = llama_new_context_with_model(model, ctx_params);
        if (!ctx) {
            fprintf(stderr, "❌ Failed to create context\n");
            llama_free_model(model);
            return 1;
        }

        const char *prompt = "You are a helpful assistant. Answer concisely.\nUser: Hello\nAssistant:";
        llama_token tokens[1024];
        int n_tokens = llama_tokenize(ctx, prompt, tokens, 1024, true);

        if (n_tokens < 0) {
            fprintf(stderr, "❌ Tokenization failed.\n");
            llama_free(ctx);
            llama_free_model(model);
            return 1;
        }

        llama_eval(ctx, tokens, n_tokens, 0, 1);
        printf("\n");

        for (int i = 0; i < 128; ++i) {
            llama_token tok = llama_sample_token(ctx);
            const char *s = llama_token_to_str(ctx, tok);
            if (!s) break;
            printf("%s", s);
            fflush(stdout);
            llama_eval(ctx, &tok, 1, n_tokens + i, 1);
        }

        printf("\n\n");

        llama_free(ctx);
        llama_free_model(model);

        return 0;
    }
}
