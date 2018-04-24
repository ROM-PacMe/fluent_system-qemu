arch ?= x86_64
kernel := build/fluentKernel-$(arch).bin
iso := build/FluentOS-$(arch)-alpha.iso

linker_script := arch/$(arch)/linker.ld
grub_cfg := arch/$(arch)/grub/grub.cfg
assembly_source_files := $(wildcard arch/$(arch)/*.asm)
assembly_object_files := $(patsubst arch/$(arch)/%.asm, \
    build/arch/$(arch)/%.o, $(assembly_source_files))

.PHONY: all clean run iso

all: $(iso)
	@qemu-system-x86_64 -cdrom $(iso)

clean:
	@rm -r build

run: $(iso)
	@qemu-system-x86_64 -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/fluentKernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
	@rm -r build/isofiles

$(kernel): $(assembly_object_files) $(linker_script)
	@ld -n -T $(linker_script) -o $(kernel) $(assembly_object_files)

# compile assembly files
build/arch/$(arch)/%.o: arch/$(arch)/%.asm	
	@mkdir -p $(shell dirname $@)
	@nasm -felf64 $< -o $@