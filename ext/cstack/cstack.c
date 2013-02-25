/**
 * Stack data structure implemented in C
 *
 * Supported operations:
 * - push
 * - pop
 * - size
 * - top
 *
 * Author: Alexei Mikhailov, 2012
 */

#include "ruby.h"
#define STACK_SIZE 1024

typedef struct {
    VALUE items[STACK_SIZE];
    unsigned short int size;
} stack;


static VALUE cStack; // stack class
static VALUE cStackOverflow; // class StackOverflow

static stack* get_stack_from_self(VALUE self) {
	stack *a_stack;
	Data_Get_Struct(self, stack, a_stack);
	return a_stack;
}


static stack* create_stack() {
	stack *a_stack = ALLOC(stack);
	a_stack->size = 0;
	return a_stack;
}


static VALUE stack_top(VALUE self) {
    stack *a_stack = get_stack_from_self(self);

    if(a_stack->size > 0) {
        return a_stack->items[a_stack->size - 1];
    } else {
        return Qnil;
    }
}


static VALUE stack_pop(VALUE self) {
    stack *a_stack = get_stack_from_self(self);

    VALUE obj;

    if(a_stack->size) {
        obj = a_stack->items[a_stack->size - 1];

        a_stack->items[a_stack->size - 1] = 0;
        a_stack->size--;

        return obj;
    } else {
        return Qnil;
    }
}


static VALUE stack_push(VALUE self, VALUE obj) {
    stack *a_stack = get_stack_from_self(self);

    if (a_stack->size >= STACK_SIZE) {
        rb_raise(cStackOverflow, "Stack overflow");
    }

    a_stack->items[a_stack->size++] = obj;

    return Qnil;
}


static VALUE stack_size(VALUE self) {
    stack *a_stack = get_stack_from_self(self);

    return INT2NUM(a_stack->size);
}


static void stack_mark(void *ptr) {
  if (ptr) {
		stack *stack = ptr;
		unsigned short int i = 0;

        for(i = 0; i < stack->size; i++) {
            rb_gc_mark(stack->items[i]);
        }
	}
}


static VALUE stack_alloc(VALUE klass) {
	stack *stack = create_stack();
	return Data_Wrap_Struct(klass, stack_mark, free, stack);
}

void Init_cstack()
{
    VALUE rb_cStandardError = rb_const_get(rb_cObject, rb_intern("StandardError"));
    cStackOverflow = rb_define_class("StackOverflow", rb_cStandardError);
    cStack = rb_define_class("CStack", rb_cObject);
    rb_define_alloc_func(cStack, stack_alloc);
    rb_define_method(cStack, "push", stack_push, 1);
    rb_define_method(cStack, "pop", stack_pop, 0);
    rb_define_method(cStack, "top", stack_top, 0);
    rb_define_method(cStack, "size", stack_size, 0);
    rb_define_alias(cStack, "length", "size");
    rb_define_alias(cStack, "last", "top");
}