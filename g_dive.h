// vim: noet:ts=8:sts=8
#ifndef __G_DIVE_H__
#define __G_DIVE_H__
/** With the help of g_dive_in, g_dive_out and g_dive_debug, the stack trace is clear.
>> [sync_wwan_enabled] 
	 [sync_wwan_enabled] g_dbus_proxy_get_cached_property returns 0x559150a28d60
	 [sync_wwan_enabled] manager->wwan_enabled = 0
	>> [engine_properties_changed] 
		>> [engine_get_airplane_mode] 
			 [engine_get_airplane_mode] manager->wwan_interesting = 0
			 [engine_get_airplane_mode] manager->wwan_enabled = 0
			 [engine_get_airplane_mode] airplane_mode = 1
		<< [engine_get_airplane_mode]
		 [engine_properties_changed] props_changed = 0x559150a5fe90
		 [engine_properties_changed] g_dbus_connection_emit_signal returns 1
	<< [engine_properties_changed]
<< [sync_wwan_enabled]
**/
#include <glib.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

typedef struct _lnode list_t;

struct _lnode {
	const char *data;
	struct _lnode *next;
};

#define G_DIVE_MAX_DEPTH 4

static list_t *g_dive_stack_sentinel = NULL;
static list_t **g_dive_stack = &g_dive_stack_sentinel;

static char g_dive_indents[G_DIVE_MAX_DEPTH + 1] = { 0 };
static size_t g_dive_stack_length = 0;

void g_dive_stack_push(const char* name);
const char* g_dive_stack_pop();

#define g_dive_in()\
do {\
	const char* name = G_STRFUNC;\
	g_debug("%s>> [%s] ", g_dive_indents, name);\
	g_dive_stack_push(name);\
} while (0)

#define g_dive_out()\
do {\
	const char *name = G_STRFUNC;\
	const char *curr_name = NULL;\
	do {\
		curr_name = g_dive_stack_pop();\
	} while (curr_name != NULL && strcmp(name, curr_name) != 0);\
	g_debug("%s<< [%s]", g_dive_indents, name);\
} while (0)

#define g_dive_debug(fmt, ...)\
do {\
	g_debug ("%s [%s] "fmt, g_dive_indents, G_STRFUNC\
		__VA_OPT__(,) __VA_ARGS__);\
} while (0)

static list_t* g_dive_list_new(const char* name) {
	list_t *node = malloc(sizeof(list_t));
	if (node == NULL) {
		// we all know it's not gonna happen.
		return NULL;
	}
	node->data = name;
	return node;
}

void g_dive_stack_push(const char* name) {
	list_t *node = g_dive_list_new(name);
	if (node == NULL) {
		return;
	}
	node->next = *g_dive_stack;
	*g_dive_stack = node;

	if (g_dive_stack_length < G_DIVE_MAX_DEPTH) {
		g_dive_indents[g_dive_stack_length] = '\t';
	}
	g_dive_stack_length++;
}

const char* g_dive_stack_pop() {
	if (*g_dive_stack == NULL) {
		return NULL;
	}
	list_t *node = *g_dive_stack;
	const char* name = node->data;
	*g_dive_stack = node->next;

	g_dive_stack_length--;
	if (g_dive_stack_length < G_DIVE_MAX_DEPTH) {
		g_dive_indents[g_dive_stack_length] = 0;
	}

	free(node);
	return name;
}

#endif // !__G_DIVE_H____G_DIVE_H__
