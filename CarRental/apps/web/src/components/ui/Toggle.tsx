import React from "react";
import { cn } from "../../lib/cn";

interface ToggleProps {
  isSelected: boolean;
  onChange: (selected: boolean) => void;
  isDisabled?: boolean;
  size?: "sm" | "md";
  slim?: boolean;
  className?: string;
}

export const Toggle: React.FC<ToggleProps> = ({
  isSelected,
  onChange,
  isDisabled = false,
  size = "sm",
  slim = false,
  className
}) => {
  const styles = {
    default: {
      sm: {
        root: "h-5 w-9 p-0.5",
        knob: cn("h-4 w-4", isSelected && "translate-x-4"),
      },
      md: {
        root: "h-6 w-11 p-0.5",
        knob: cn("h-5 w-5", isSelected && "translate-x-5"),
      },
    },
    slim: {
      sm: {
        root: "h-4 w-8",
        knob: cn("h-4 w-4", isSelected && "translate-x-4"),
      },
      md: {
        root: "h-5 w-10",
        knob: cn("h-5 w-5", isSelected && "translate-x-5"),
      },
    },
  };

  const classes = slim ? styles.slim[size] : styles.default[size];

  return (
    <button
      type="button"
      onClick={() => !isDisabled && onChange(!isSelected)}
      disabled={isDisabled}
      className={cn(
        "relative inline-flex shrink-0 cursor-pointer rounded-full transition-colors duration-200 ease-in-out focus:outline-none",
        isSelected ? "bg-green-500" : "bg-white/10 border border-white/5",
        isDisabled && "cursor-not-allowed opacity-50",
        classes.root,
        className
      )}
    >
      <span
        style={{
          transition: "transform 0.15s ease-in-out",
        }}
        className={cn(
          "pointer-events-none inline-block rounded-full bg-white shadow-sm transform transition duration-150 ease-in-out",
          classes.knob
        )}
      />
    </button>
  );
};
